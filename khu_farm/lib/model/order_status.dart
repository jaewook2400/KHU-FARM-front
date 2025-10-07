import 'package:flutter/material.dart';

class DeliveryStatus {
  final String displayName; // 서버에서 받은 원본 상태 또는 UI에 표시할 이름
  final String stepName;    // stepStatuses와 매칭될 UI 단계 이름
  final Color color;

  const DeliveryStatus(this.displayName, this.stepName, this.color);
}

// 서버 상태(key)를 UI 단계(stepName)와 매핑한 맵
const Map<String, DeliveryStatus> statusMap = {
  // '결제 완료' 단계에 매핑
  'PAYMENT_STANDBY': DeliveryStatus('결제 대기', '결제 완료', Colors.grey),
  'ORDER_COMPLETED': DeliveryStatus('주문 완료', '결제 완료', Colors.orange),
// {'ORDER_COMPLETED', 'PREPARING_SHIPMENT', 'SHIPMENT_COMPLETED'}
  // '배송 준비중' 단계에 매핑
  'PREPARING_SHIPMENT': DeliveryStatus('배송 준비중', '배송 준비중', Colors.blueAccent),

  // '배송중' 단계에 매핑
  'SHIPPING': DeliveryStatus('배송중', '배송중', Colors.green),

  // '배송 완료' 단계에 매핑
  'SHIPMENT_COMPLETED': DeliveryStatus('배송 완료', '배송 완료', Colors.blue),
  //'배송완료': DeliveryStatus('배송 완료', '배송 완료', Colors.blue),

  // 매핑되지 않는 기타 상태들 (stepName을 비워둠)
  'ORDER_CANCELLED': DeliveryStatus('주문 취소', '', Colors.red),
  'ORDER_FAILED': DeliveryStatus('주문 실패', '', Colors.purple),
  'REFUND_REQUESTED': DeliveryStatus('환불 대기', '', Colors.red),
  'REFUND_DENIED': DeliveryStatus('환불 거부', '', Colors.grey),
  'PAYMENT_PARTIALLY_REFUNDED': DeliveryStatus('부분 환불', '', Colors.deepOrange),
  '알 수 없음': DeliveryStatus('알 수 없음', '', Colors.black),
};