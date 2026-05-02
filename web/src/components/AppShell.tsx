import { QRCodeSVG } from 'qrcode.react'
import type { ReactNode } from 'react'
import iconUrl from '../assets/icon.png'

export const ANDROID_DOWNLOAD_URL =
  'https://github.com/idlepoe/repeat_exam/releases'

export const IOS_APP_STORE_URL =
  'https://apps.apple.com/us/app/%EA%B4%91%EA%B3%A0%EC%97%86%EB%8A%94%EC%A0%9C%EA%B3%BC%EC%A0%9C%EB%B9%B5%ED%95%84%EA%B8%B0%EA%B8%B0%EC%B6%9C%ED%9A%8C%EB%8F%85/id6762967536'

const QR_SIZE = 120

type Props = {
  children: ReactNode
}

export function AppShell({ children }: Props) {
  return (
    <div className="app-shell">
      <aside className="app-shell__rail app-shell__rail--left" aria-label="앱 소개">
        <div className="app-shell__intro">
          <img
            className="app-shell__icon"
            src={iconUrl}
            width={72}
            height={72}
            alt=""
          />
          <h1 className="app-shell__title">광고없는제과제빵필기기출회독</h1>
          <p className="app-shell__lead">
            제과/제빵 필기 기출문제를 반복해서 학습할 수 있도록 만든 회독형 학습
            앱입니다.
          </p>

          <h2 className="app-shell__h2">앱 소개</h2>
          <ul className="app-shell__list">
            <li>제과 기출문제 40회독, 제빵 기출문제 40회독을 제공합니다.</li>
            <li>
              문제를 풀어서 채점하는 방식이 아니라, 정답을 바로 확인하며 반복
              암기하는 학습 방식에 초점을 맞췄습니다.
            </li>
            <li>
              각 문제에서 정답은 즉시 표시되며, 문제-정답을 반복적으로 익히는 데
              최적화되어 있습니다.
            </li>
            <li>
              학습 진행 상황이 저장되어, 앱을 다시 실행해도 이어서 학습할 수
              있습니다.
            </li>
            <li>어떠한 광고도 포함되어 있지 않습니다.</li>
            <li>모바일에서 사용하기 쉽도록 화면과 학습 흐름을 구성했습니다.</li>
          </ul>

          <h2 className="app-shell__h2">이런 분께 추천합니다</h2>
          <ul className="app-shell__list">
            <li>기출문제를 빠르게 여러 번 회독하고 싶은 분</li>
            <li>문제와 정답을 세트로 외우는 방식이 잘 맞는 분</li>
            <li>광고 없이 집중해서 학습하고 싶은 분</li>
          </ul>

          <h2 className="app-shell__h2">학습 방식</h2>
          <ol className="app-shell__ol">
            <li>제과 또는 제빵 과목을 선택합니다.</li>
            <li>문제를 확인하면서 정답을 바로 함께 학습합니다.</li>
            <li>반복 회독을 통해 문제와 정답을 자연스럽게 암기합니다.</li>
          </ol>
        </div>
      </aside>

      <div className="app-shell__center">{children}</div>

      <aside className="app-shell__rail app-shell__rail--right" aria-label="앱 다운로드">
        <div className="app-shell__qrBlock">
          <p className="app-shell__qrLabel">Android</p>
          <p className="app-shell__qrSub">GitHub Releases</p>
          <a
            className="app-shell__qrLink"
            href={ANDROID_DOWNLOAD_URL}
            target="_blank"
            rel="noopener noreferrer"
            aria-label="Android 앱 다운로드 (GitHub Releases)"
          >
            <QRCodeSVG
              value={ANDROID_DOWNLOAD_URL}
              size={QR_SIZE}
              level="M"
              className="app-shell__qrSvg"
            />
          </a>
        </div>
        <div className="app-shell__qrBlock">
          <p className="app-shell__qrLabel">iOS</p>
          <p className="app-shell__qrSub">App Store</p>
          <a
            className="app-shell__qrLink"
            href={IOS_APP_STORE_URL}
            target="_blank"
            rel="noopener noreferrer"
            aria-label="iOS 앱 (App Store)"
          >
            <QRCodeSVG
              value={IOS_APP_STORE_URL}
              size={QR_SIZE}
              level="M"
              className="app-shell__qrSvg"
            />
          </a>
        </div>
      </aside>
    </div>
  )
}
