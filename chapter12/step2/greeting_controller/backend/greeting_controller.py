import kopf
import logging

# 로깅 설정: 파드 로그에서 컨트롤러의 출력을 볼 수 있도록 합니다.
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# 'greetings.kosa.go.kr' 리소스가 생성될 때 호출되는 함수
@kopf.on.create('greetings.kosa.go.kr')
def create_fn(spec, name, namespace, logger, **kwargs):
    message = spec.get('message', 'No message provided')
    recipient = spec.get('recipient', 'No recipient specified')
    logger.info(f"Greeting '{name}' created in namespace '{namespace}'. Message: '{message}' to '{recipient}'")
    # 여기에 실제 작업을 수행하는 로직을 추가합니다.
    # 예: 이메일 전송, 웹훅 호출, 다른 쿠버네티스 리소스 생성 등
    return {'message': f"Greeting '{name}' processed on creation."}

# 'greetings.kosa.go.kr' 리소스가 업데이트될 때 호출되는 함수
@kopf.on.update('greetings.kosa.go.kr')
def update_fn(spec, old, new, name, namespace, logger, **kwargs):
    message = spec.get('message', 'No message provided')
    recipient = spec.get('recipient', 'No recipient specified')
    logger.info(f"Greeting '{name}' updated in namespace '{namespace}'. New Message: '{message}' to '{recipient}'")
    return {'message': f"Greeting '{name}' processed on update."}

# 'greetings.kosa.go.kr' 리소스가 삭제될 때 호출되는 함수
@kopf.on.delete('greetings.kosa.go.kr')
def delete_fn(spec, name, namespace, logger, **kwargs):
    message = spec.get('message', 'No message provided')
    recipient = spec.get('recipient', 'No recipient specified')
    logger.info(f"Greeting '{name}' deleted from namespace '{namespace}'. Was: '{message}' to '{recipient}'")
    return {'message': f"Greeting '{name}' processed on deletion."}