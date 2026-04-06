import kopf
import logging
import kubernetes.client as k8s
from kubernetes.client.rest import ApiException

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

FINALIZER = "appdeploy.kosa.go.kr/finalizer"

def build_resources(spec):
    # 기본값
    cpu = spec.get("cpu", "100")       # millicores
    memory = spec.get("memory", "128") # Mi

    # requests
    cpu_request = f"{cpu}m"
    mem_request = f"{memory}Mi"

    # limits = 2배
    cpu_limit = f"{int(cpu) * 2}m"
    mem_limit = f"{int(memory) * 2}Mi"

    return k8s.V1ResourceRequirements(
        requests={
            "cpu": cpu_request,
            "memory": mem_request,
        },
        limits={
            "cpu": cpu_limit,
            "memory": mem_limit,
        }
    )


@kopf.on.create('kosa.go.kr', 'v1', 'appdeploys')
def create_appdeployment(spec, name, namespace, meta, patch, **kwargs):

    # 삭제 중이면 아무 것도 하지 않음
    if meta.get("deletionTimestamp"):
        return

    # 🔥 finalizer 추가 (정석)
    patch.metadata.setdefault("finalizers", []).append(FINALIZER)

    apps = k8s.AppsV1Api()
    core = k8s.CoreV1Api()
    autoscaling = k8s.AutoscalingV2Api()

    image = spec['image']
    replicas = spec.get('replicas', 1)
    port = spec.get('port', 8080)
    
    resources = build_resources(spec)

    logger.info(f"[CREATE] appdeploys {name}")

    apps.create_namespaced_deployment(
        namespace,
        k8s.V1Deployment(
            metadata=k8s.V1ObjectMeta(name=name),
            spec=k8s.V1DeploymentSpec(
                replicas=replicas,
                selector={'matchLabels': {'app': name}},
                template=k8s.V1PodTemplateSpec(
                    metadata=k8s.V1ObjectMeta(labels={'app': name}),
                    spec=k8s.V1PodSpec(
                        containers=[k8s.V1Container(
                            name=name,
                            image=image,
                            ports=[k8s.V1ContainerPort(container_port=port)],
                            resources=resources
                        )]
                    )
                )
            )
        )
    )

    core.create_namespaced_service(
        namespace,
        k8s.V1Service(
            metadata=k8s.V1ObjectMeta(name=name),
            spec=k8s.V1ServiceSpec(
                selector={'app': name},
                ports=[k8s.V1ServicePort(port=port, target_port=port)]
            )
        )
    )

    if spec.get('autoscaling', {}).get('enabled'):
        autoscaling.create_namespaced_horizontal_pod_autoscaler(
            namespace,
            k8s.V2HorizontalPodAutoscaler(
                metadata=k8s.V1ObjectMeta(name=name),
                spec=k8s.V2HorizontalPodAutoscalerSpec(
                    min_replicas=spec['autoscaling']['min'],
                    max_replicas=spec['autoscaling']['max'],
                    scale_target_ref=k8s.V2CrossVersionObjectReference(
                        api_version="apps/v1",
                        kind="Deployment",
                        name=name
                    ),
                    metrics=[{
                        "type": "Resource",
                        "resource": {
                            "name": "cpu",
                            "target": {
                                "type": "Utilization",
                                "averageUtilization": spec['autoscaling']['cpu']
                            }
                        }
                    }]
                )
            )
        )


@kopf.on.delete('kosa.go.kr', 'v1', 'appdeploys')
def delete_appdeployment(name, namespace, meta, patch, **kwargs):
    apps = k8s.AppsV1Api()
    core = k8s.CoreV1Api()
    autoscaling = k8s.AutoscalingV2Api()

    def safe_delete(fn, *args, **kwargs):
        try:
            fn(*args, **kwargs)
        except ApiException as e:
            if e.status != 404:
                raise

    safe_delete(autoscaling.delete_namespaced_horizontal_pod_autoscaler, name, namespace)
    safe_delete(core.delete_namespaced_service, name, namespace)
    safe_delete(apps.delete_namespaced_deployment, name, namespace, propagation_policy="Foreground")

    logger.info(f"[DELETE] appdeploys {name} cleaned")

    patch.metadata["finalizers"] = [
        f for f in meta.get("finalizers", [])
        if f != FINALIZER
    ]        
