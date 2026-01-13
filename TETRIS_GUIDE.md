# 🎮 테트리스 게임 제작 및 AWS EC2 CI/CD 배포 가이드

이 가이드는 간단한 테트리스 게임을 만들고, 이를 AWS EC2 서버에 GitHub Actions를 이용해 자동으로 배포하는 전 과정을 다룹니다.

---

## 1단계: 테트리스 게임 개발 (Frontend)

가장 먼저 로컬 환경에서 실행 가능한 테트리스 게임을 만듭니다. 별도의 프레임워크 없이 순수 HTML, CSS, JavaScript를 사용합니다.

### 1.1 프로젝트 구조
```text
tetris-app/
├── index.html
├── style.css
└── script.js
```

### 1.2 HTML 작성 (`index.html`)
게임 화면을 그릴 `canvas` 엘리먼트와 간단한 안내 메시지를 포함합니다.

```html
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Neon Tetris</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="game-container">
        <h1>NEON TETRIS</h1>
        <canvas id="tetris" width="240" height="400"></canvas>
        <div class="info">
            <p>점수: <span id="score">0</span></p>
            <p>조작: 화살표 키 (이동/회전)</p>
        </div>
    </div>
    <script src="script.js"></script>
</body>
</html>
```

### 1.3 CSS 스타일링 (`style.css`)
네온 테마의 어두운 배경과 화려한 효과를 적용합니다.

```css
body {
    background: #202028;
    color: #fff;
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    display: flex;
    justify-content: center;
    align-items: center;
    height: 100vh;
    margin: 0;
}

.game-container {
    text-align: center;
}

h1 {
    font-size: 3rem;
    color: #0ff;
    text-shadow: 0 0 10px #0ff, 0 0 20px #0ff;
}

canvas {
    border: 2px solid #fff;
    box-shadow: 0 0 20px rgba(255, 255, 255, 0.2);
    background-color: #000;
}

.info {
    margin-top: 20px;
    font-size: 1.2rem;
}

#score {
    color: #f0f;
    font-weight: bold;
}
```

### 1.4 JavaScript 로직 (`script.js`)
테트리스의 핵심 로직(블록 생성, 이동, 충돌 감지, 줄 제거)을 구현합니다.

```javascript
const canvas = document.getElementById('tetris');
const context = canvas.getContext('2d');
const scoreElement = document.getElementById('score');

context.scale(20, 20);

// 줄 제거 처리
function arenaSweep() {
    let rowCount = 1;
    outer: for (let y = arena.length - 1; y > 0; --y) {
        for (let x = 0; x < arena[y].length; ++x) {
            if (arena[y][x] === 0) {
                continue outer;
            }
        }
        const row = arena.splice(y, 1)[0].fill(0);
        arena.unshift(row);
        ++y;
        player.score += rowCount * 10;
        rowCount *= 2;
    }
}

// 충돌 감지
function collide(arena, player) {
    const [m, o] = [player.matrix, player.pos];
    for (let y = 0; y < m.length; ++y) {
        for (let x = 0; x < m[y].length; ++x) {
            if (m[y][x] !== 0 &&
               (arena[y + o.y] && arena[y + o.y][x + o.x]) !== 0) {
                return true;
            }
        }
    }
    return false;
}

// 매트릭스 생성 (게임판)
function createMatrix(w, h) {
    const matrix = [];
    while (h--) {
        matrix.push(new Array(w).fill(0));
    }
    return matrix;
}

// 블록 모양 정의
function createPiece(type) {
    if (type === 'I') {
        return [
            [0, 1, 0, 0],
            [0, 1, 0, 0],
            [0, 1, 0, 0],
            [0, 1, 0, 0],
        ];
    } else if (type === 'L') {
        return [
            [0, 2, 0],
            [0, 2, 0],
            [0, 2, 2],
        ];
    } else if (type === 'J') {
        return [
            [0, 3, 0],
            [0, 3, 0],
            [3, 3, 0],
        ];
    } else if (type === 'O') {
        return [
            [4, 4],
            [4, 4],
        ];
    } else if (type === 'Z') {
        return [
            [5, 5, 0],
            [0, 5, 5],
            [0, 0, 0],
        ];
    } else if (type === 'S') {
        return [
            [0, 6, 6],
            [6, 6, 0],
            [0, 0, 0],
        ];
    } else if (type === 'T') {
        return [
            [0, 7, 0],
            [7, 7, 7],
            [0, 0, 0],
        ];
    }
}

// 드로잉 함수
function draw() {
    context.fillStyle = '#000';
    context.fillRect(0, 0, canvas.width, canvas.height);
    drawMatrix(arena, {x: 0, y: 0});
    drawMatrix(player.matrix, player.pos);
}

function drawMatrix(matrix, offset) {
    matrix.forEach((row, y) => {
        row.forEach((value, x) => {
            if (value !== 0) {
                context.fillStyle = colors[value];
                context.fillRect(x + offset.x, y + offset.y, 1, 1);
            }
        });
    });
}

// 병합 (바닥에 닿았을 때)
function merge(arena, player) {
    player.matrix.forEach((row, y) => {
        row.forEach((value, x) => {
            if (value !== 0) {
                arena[y + player.pos.y][x + player.pos.x] = value;
            }
        });
    });
}

// 회전
function rotate(matrix, dir) {
    for (let y = 0; y < matrix.length; ++y) {
        for (let x = 0; x < y; ++x) {
            [
                matrix[x][y],
                matrix[y][x],
            ] = [
                matrix[y][x],
                matrix[x][y],
            ];
        }
    }
    if (dir > 0) {
        matrix.forEach(row => row.reverse());
    } else {
        matrix.reverse();
    }
}

// 낙하
function playerDrop() {
    player.pos.y++;
    if (collide(arena, player)) {
        player.pos.y--;
        merge(arena, player);
        playerReset();
        arenaSweep();
        updateScore();
    }
    dropCounter = 0;
}

// 이동
function playerMove(dir) {
    player.pos.x += dir;
    if (collide(arena, player)) {
        player.pos.x -= dir;
    }
}

// 리셋 (새 블록)
function playerReset() {
    const pieces = 'ILJOTSZ';
    player.matrix = createPiece(pieces[pieces.length * Math.random() | 0]);
    player.pos.y = 0;
    player.pos.x = (arena[0].length / 2 | 0) -
                   (player.matrix[0].length / 2 | 0);
    if (collide(arena, player)) {
        arena.forEach(row => row.fill(0));
        player.score = 0;
        updateScore();
    }
}

// 회전 조작
function playerRotate(dir) {
    const pos = player.pos.x;
    let offset = 1;
    rotate(player.matrix, dir);
    while (collide(arena, player)) {
        player.pos.x += offset;
        offset = -(offset + (offset > 0 ? 1 : -1));
        if (offset > player.matrix[0].length) {
            rotate(player.matrix, -dir);
            player.pos.x = pos;
            return;
        }
    }
}

// 점수 업데이트
function updateScore() {
    scoreElement.innerText = player.score;
}

const colors = [
    null,
    '#FF0D72',
    '#0DC2FF',
    '#0DFF72',
    '#F538FF',
    '#FF8E0D',
    '#FFE138',
    '#3877FF',
];

const arena = createMatrix(12, 20);

const player = {
    pos: {x: 0, y: 0},
    matrix: null,
    score: 0,
};

// 키 입력 이벤트
document.addEventListener('keydown', event => {
    if (event.keyCode === 37) {
        playerMove(-1);
    } else if (event.keyCode === 39) {
        playerMove(1);
    } else if (event.keyCode === 40) {
        playerDrop();
    } else if (event.keyCode === 81) {
        playerRotate(-1);
    } else if (event.keyCode === 87) {
        playerRotate(1);
    }
});

let dropCounter = 0;
let dropInterval = 1000;
let lastTime = 0;

function update(time = 0) {
    const deltaTime = time - lastTime;
    lastTime = time;

    dropCounter += deltaTime;
    if (dropCounter > dropInterval) {
        playerDrop();
    }

    draw();
    requestAnimationFrame(update);
}

playerReset();
updateScore();
update();
```

---

## 2단계: AWS EC2 서버 환경 구축

이제 작성한 게임을 웹에 띄울 서버를 준비합니다.

### 2.1 EC2 인스턴스 생성
1. AWS Console에서 **EC2** 서비스로 이동합니다.
2. **인스턴스 시작**을 클릭합니다.
   - **이름**: `tetris-server`
   - **OS**: `Ubuntu Server 22.04 LTS` (Free Tier)
   - **인스턴스 유형**: `t2.micro`
   - **키 페어**: 기존 키가 없다면 새로 생성하여 저장합니다 (SSH 접속용).

### 2.2 보안 그룹 설정
인스턴스가 외부 웹 브라우저로부터 접속을 받을 수 있도록 설정해야 합니다.
- **인바운드 규칙**:
  - `SSH (22)`: 내 IP (관리용)
  - `HTTP (80)`: 위치 무관 (0.0.0.0/0)

### 2.3 서버 접속 및 Nginx 설치
터미널(PowerShell 또는 CMD)에서 SSH로 서버에 접속합니다.
```bash
ssh -i "your-key.pem" ubuntu@your-ec2-public-ip
```

서버 접속 후 Nginx를 설치합니다.
```bash
sudo apt update
sudo apt install nginx -y
```

> [!TIP]
> Nginx를 설치하면 즉시 서버의 Public IP로 접속했을 때 "Welcome to nginx!" 페이지가 보일 것입니다.

---

## 3단계: CI/CD 파이프라인 구성 (GitHub Actions)

코드를 GitHub에 올리면 자동으로 EC2 서버에 반영되도록 설정합니다.

### 3.1 GitHub Repository 생성 및 업로드
1. GitHub에서 새로운 저장소를 만듭니다 (`tetris-game`).
2. 로컬에서 코드를 푸시합니다.
   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/your-username/tetris-game.git
   git push -u origin main
   ```

### 3.2 GitHub Secrets 등록
GitHub 저장소의 **Settings > Secrets and variables > Actions** 에서 다음 정보를 등록합니다.
- `EC2_SSH_KEY`: `.pem` 파일의 전체 내용
- `EC2_HOST`: EC2 인스턴스의 Public IP
- `EC2_USERNAME`: `ubuntu`

### 3.3 Workflow 파일 작성 (`.github/workflows/deploy.yml`)
프로젝트 루트에 폴더와 파일을 생성합니다.

```yaml
name: Deploy to EC2

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Deploy to EC2 via SSH
        uses: appleboy/scp-action@master
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ${{ secrets.EC2_USERNAME }}
          key: ${{ secrets.EC2_SSH_KEY }}
          source: "*"
          target: "/var/www/html"
          strip_components: 0
```

> [!CAUTION]
> `/var/www/html` 디렉토리에 쓰기 권한이 필요할 수 있습니다. EC2에서 `sudo chown -R ubuntu:ubuntu /var/www/html` 명령을 한번 실행해 주어야 합니다.

---

## 4단계: 마무리 및 확인

1. 이제 코드를 수정하고 `git push`를 하면 GitHub Actions가 동작합니다.
2. 완료 후 EC2의 Public IP로 접속하여 내가 만든 테트리스 게임이 잘 나오는지 확인하세요! 🚀
