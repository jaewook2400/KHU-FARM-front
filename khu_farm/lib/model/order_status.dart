import 'package:flutter/material.dart';

class DeliveryStatus {
  final String displayName;
  final Color color;
  const DeliveryStatus(this.displayName, this.color);
}

// 2. 서버에서 오는 한글 상태 문자열을 키로 사용하는 맵(Map)
const Map<String, DeliveryStatus> statusMap = {
  '결제 대기': DeliveryStatus('결제 대기', Colors.grey),
  '주문 완료': DeliveryStatus('주문 완료', Colors.orange),
  '배송 준비중': DeliveryStatus('배송 준비중', Colors.blueAccent),
  '배송중': DeliveryStatus('배송 중', Colors.green), // '배송중' -> '배송 중' 오타 수정
  '배달 완료': DeliveryStatus('배송 완료', Colors.blue), // '배달 완료' -> '배송 완료'
  '주문 취소': DeliveryStatus('주문 취소', Colors.red),
  '주문 실패': DeliveryStatus('주문 실패', Colors.redAccent),
  '환불 대기': DeliveryStatus('환불 대기', Colors.purple),
  '부분 환불': DeliveryStatus('부분 환불', Colors.deepOrange),
  '알 수 없음': DeliveryStatus('알 수 없음', Colors.black), // 기본값
};