//
//  MainMessages.swift
//  Sodam
//
//  Created by 손겸 on 1/21/25.
//

import Foundation

enum MainMessages: String, CaseIterable {
    case message1 = "행복은 먼 곳에 있지 않아요. 지금 이 순간에 왔을지도요."
    case message2 = "작은 것에 감사할 줄 알 때, 큰 행복이 찾아온답니다."
    case message3 = "당신은 이미 충분히 빛나는, 전구 같은 사람!"
    case message4 = "웃음은 마음의 태양이죠. 오늘도 환하게 웃어보기!"
    case message5 = "당신이 라면만 먹어도 행복하다면, 그게 행복이에요."
    case message6 = "좋은 생각이 좋은 하루를 만들어준답니다."
    case message7 = "오늘 하루, 고생 많았어요. 화이팅"
    case message8 = "작은 친절 하나가 소소한 행복을 만듭니다."
    case message9 = "행복은 길 위에 놓인 작은 꽃과 같습니다. 걸음을 멈추고 둘러보아요."
    case message10 = "당신이 사랑받고 있다는 사실을 잊지 말기."
    case message11 = "소소한 행복은 목적지가 아니라 여정입니다."
    case message12 = "어제보다 나은 오늘, 그것이 행복이죠. 별거 있나요?"
    case message13 = "소소한 행복은 언제나 당신 곁에 있어요."
    case message14 = "작은 성공을 축하하는 건 큰 행복의 시작이랍니다."
    case message15 = "행복은 다른 사람의 미소를 보는 데서 시작될 수 있답니다."
    case message16 = "당신의 마음속엔 이미 행복의 씨앗이 있네요."
    case message17 = "힘들 때일수록 스스로를 응원해주세요. 행복은 당신을 기다립니다."
    case message18 = "행복은 완벽함이 아닌, 불완전함을 사랑하는 마음에서 오는 것."
    case message19 = "자신을 소중히 여길 때, 행복은 더 자주 찾아온답니다."
    case message20 = "지금 느끼는 감사가 내일의 행복을 만들어줄거에요"
    
    // 첫번쨔 메세지는 별도로 관리
    static let firstMessage = "소소하고 확실한 행복으로 행담이를 깨워볼까요?"
    
    static func messageForLevel(_ level: Int, name: String) -> String {
        switch level {
        case 1:
            return "드디어 알을 깨고 아기 \(name)가 눈을 마주치네요!"
        case 2:
            return "하트 윙크 발사하는 사랑스러운 \(name)로 성장했네요!"
        case 3:
            return "어엿한 \(name)로 성장 완료!"
        case 4:
            return "소확행을 좋아하는 \(name)에게 행복한 기억을 더 줘볼까요?"
        case 5:
            return "\(name)가 당신의 소확행을 배부르게 먹고 보관되었습니다. 다음엔 누가 나올까요?"
        default:
            return "행복의 새로운 단계를 향해 나아가고 있어요!"
        }
    }
    
    // 랜덤으로 메세지 반환하기 (firstMessage는 제외하기)
    static func getRandomMessage() -> String {
        let randomMessages = Self.allCases.map { $0.rawValue }
        let randomMessage = randomMessages.randomElement() ?? "오늘의 소확행 기록하기."
        
        // 쉼표를 기준으로 줄바꿈 추가
        let formattedMessage = randomMessage.replacingOccurrences(of: ",", with: ",\n")
        return formattedMessage
    }
}
