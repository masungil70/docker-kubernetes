#!/bin/bash

# ─────────────────────────────────────────────────────────
# NFS 마운트 자동 설정 스크립트 (로그 및 연결 체크 포함)
#
# 사용 예: sudo ./nfs_mount_setup.sh 192.168.80.132 /mnt/nfs_share/nginx_html
# ─────────────────────────────────────────────────────────

LOGFILE="/var/log/nfs_mount_setup.log"

log_info() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO]  $1" | tee -a "$LOGFILE"
}

log_error() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" | tee -a "$LOGFILE" >&2
}

# ==== 인자 확인 ====
if [ "$EUID" -ne 0 ]; then
  log_error "이 스크립트는 root 권한으로 실행되어야 합니다."
  exit 1
fi

NFS_SERVER_IP="$1"
NFS_REMOTE_PATH="$2"
LOCAL_MOUNT_PATH="$2"

if [ -z "$NFS_SERVER_IP" ] || [ -z "$NFS_REMOTE_PATH" ]; then
  log_error "사용법: sudo $0 <NFS_SERVER_IP> <NFS_공유_경로>"
  log_error "예시: sudo $0 192.168.80.132 /mnt/nfs_share/nginx_html"
  exit 1
fi

log_info "스크립트 시작: NFS 서버=${NFS_SERVER_IP}, 로컬 경로=${LOCAL_MOUNT_PATH}"

# ==== 서버 연결 체크 ====
ping -c 2 "$NFS_SERVER_IP" &> /dev/null
if [ $? -ne 0 ]; then
  log_error "NFS 서버 (${NFS_SERVER_IP}) 에 연결할 수 없습니다."
  exit 1
else
  log_info "NFS 서버 (${NFS_SERVER_IP}) 연결 확인됨."
fi

# ==== NFS 클라이언트 설치 ====
log_info "패키지 업데이트 및 설치: nfs-common, vim"
apt-get update -y >> "$LOGFILE" 2>&1
apt-get install -y nfs-common vim >> "$LOGFILE" 2>&1

# ==== 마운트 디렉토리 생성 ====
log_info "로컬 마운트 디렉토리 생성: ${LOCAL_MOUNT_PATH}"
mkdir -p "$LOCAL_MOUNT_PATH"

# ==== 마운트 테스트 ====
log_info "NFS 공유 폴더 마운트 테스트: ${NFS_SERVER_IP}:${NFS_REMOTE_PATH} → ${LOCAL_MOUNT_PATH}"
mount "${NFS_SERVER_IP}:${NFS_REMOTE_PATH}" "$LOCAL_MOUNT_PATH"
if [ $? -ne 0 ]; then
  log_error "마운트 실패. 서버 주소 또는 경로를 확인하세요."
  exit 1
fi

# ==== 마운트 상태 확인 ====
log_info "마운트 상태 확인 중..."
df -h | grep "$LOCAL_MOUNT_PATH" | tee -a "$LOGFILE"
ls -l "$LOCAL_MOUNT_PATH" | tee -a "$LOGFILE"

# ==== /etc/fstab에 항목 등록 ====
FSTAB_ENTRY="${NFS_SERVER_IP}:${NFS_REMOTE_PATH}    ${LOCAL_MOUNT_PATH}   nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0"
if grep -qxF "$FSTAB_ENTRY" /etc/fstab; then
  log_info "/etc/fstab에 이미 등록된 항목입니다."
else
  log_info "/etc/fstab에 마운트 항목 추가"
  echo "$FSTAB_ENTRY" >> /etc/fstab
fi

# ==== 설정 적용 ====
log_info "기존 마운트 해제 및 fstab 기준 재마운트"
umount "$LOCAL_MOUNT_PATH" >> "$LOGFILE" 2>&1
mount -a >> "$LOGFILE" 2>&1

log_info "최종 마운트 상태 확인 중..."
df -h | grep "$LOCAL_MOUNT_PATH" | tee -a "$LOGFILE"

log_info "스크립트 실행 완료"
