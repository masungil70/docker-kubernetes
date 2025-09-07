# step7/benchmark/benchmark.py
import asyncio
import httpx
import time
import random
import string
import argparse
from rich.console import Console
from rich.table import Table

# Rich Console 객체 생성 (결과를 예쁘게 출력하기 위함)
console = Console()

# 랜덤 문자열을 생성하는 함수 (테스트 데이터용)
def random_string(length=10):
    letters = string.ascii_lowercase
    return ''.join(random.choice(letters) for i in range(length))

# 쓰기(POST) 성능을 테스트하는 비동기 함수
async def test_writes(url: str, num_requests: int, concurrency: int):
    console.print(f"[bold cyan]🚀 시작: 쓰기 성능 테스트...[/bold cyan]")
    # 비동기 HTTP 클라이언트 생성
    async with httpx.AsyncClient() as client:
        # 동시에 실행할 작업들을 담을 리스트
        tasks = []
        # 성공/실패 카운트
        success_count = 0
        failure_count = 0

        # POST 요청을 보내는 내부 함수
        async def post_item(item_name: str):
            nonlocal success_count, failure_count
            try:
                response = await client.post(f"{url}/items/", json={"name": item_name}, timeout=20)
                if 200 <= response.status_code < 300:
                    success_count += 1
                else:
                    failure_count += 1
            except httpx.RequestError as e:
                console.print(f"[red]Request failed: {e}[/red]")
                failure_count += 1

        start_time = time.time()

        # 지정된 수의 요청을 동시성(concurrency)에 맞게 실행
        for i in range(num_requests):
            task = asyncio.create_task(post_item(f"item_{random_string()}"))
            tasks.append(task)
            # 동시 실행 개수를 제어
            if len(tasks) >= concurrency:
                await asyncio.gather(*tasks)
                tasks = []
        
        # 남은 작업 실행
        if tasks:
            await asyncio.gather(*tasks)

        end_time = time.time()
        total_time = end_time - start_time
        rps = num_requests / total_time if total_time > 0 else 0

        return total_time, rps, success_count, failure_count

# 읽기(GET) 성능을 테스트하는 비동기 함수
async def test_reads(url: str, num_requests: int, concurrency: int):
    console.print(f"[bold cyan]🚀 시작: 읽기 성능 테스트...[/bold cyan]")
    async with httpx.AsyncClient() as client:
        tasks = []
        success_count = 0
        failure_count = 0

        async def get_items():
            nonlocal success_count, failure_count
            try:
                response = await client.get(f"{url}/items/", timeout=20)
                if 200 <= response.status_code < 300:
                    success_count += 1
                else:
                    failure_count += 1
            except httpx.RequestError as e:
                console.print(f"[red]Request failed: {e}[/red]")
                failure_count += 1

        start_time = time.time()

        for i in range(num_requests):
            task = asyncio.create_task(get_items())
            tasks.append(task)
            if len(tasks) >= concurrency:
                await asyncio.gather(*tasks)
                tasks = []
        
        if tasks:
            await asyncio.gather(*tasks)

        end_time = time.time()
        total_time = end_time - start_time
        rps = num_requests / total_time if total_time > 0 else 0

        return total_time, rps, success_count, failure_count

# 결과를 테이블 형태로 출력하는 함수
def print_results(title: str, total_time: float, rps: float, success: int, failure: int, total_req: int):
    table = Table(title=f"[bold green]{title} 결과[/bold green]")
    table.add_column("항목", justify="right", style="cyan", no_wrap=True)
    table.add_column("값", style="magenta")

    table.add_row("총 요청 수", str(total_req))
    table.add_row("성공", f"[green]{success}[/green]")
    table.add_row("실패", f"[red]{failure}[/red]")
    table.add_row("총 소요 시간 (초)", f"{total_time:.2f}")
    table.add_row("초당 요청 수 (RPS)", f"{rps:.2f}")

    console.print(table)

# 메인 실행 함수
if __name__ == "__main__":
    # 커맨드라인 인자 파싱
    parser = argparse.ArgumentParser(description="FastAPI 성능 테스트 스크립트")
    parser.add_argument("url", type=str, help="테스트할 API의 기본 URL (예: http://127.0.0.1:8080)")
    parser.add_argument("-n", "--num_requests", type=int, default=1000, help="총 요청 수")
    parser.add_argument("-c", "--concurrency", type=int, default=100, help="동시 요청 수")
    args = parser.parse_args()

    # 쓰기 테스트 실행 및 결과 출력
    write_time, write_rps, write_success, write_failure = asyncio.run(test_writes(args.url, args.num_requests, args.concurrency))
    print_results("쓰기 (POST /items/)", write_time, write_rps, write_success, write_failure, args.num_requests)

    console.print("\n") # 줄바꿈

    # 읽기 테스트 실행 및 결과 출력
    read_time, read_rps, read_success, read_failure = asyncio.run(test_reads(args.url, args.num_requests, args.concurrency))
    print_results("읽기 (GET /items/)", read_time, read_rps, read_success, read_failure, args.num_requests)
