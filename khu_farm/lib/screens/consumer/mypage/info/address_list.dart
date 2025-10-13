import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:khu_farm/model/address.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/services/storage_service.dart';

import '../../../../shared/widgets/top_norch_header.dart';


class ConsumerAddressListScreen extends StatefulWidget {
  const ConsumerAddressListScreen({super.key});

  @override
  State<ConsumerAddressListScreen> createState() =>
      _ConsumerAddressListScreenState();
}

class _ConsumerAddressListScreenState extends State<ConsumerAddressListScreen> {
  List<Address> _addresses = [];
  bool _isLoading = true;

  final ScrollController _scrollController = ScrollController();
  bool _isFetchingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchAddresses(); // ✨ Storage 대신 API에서 바로 불러오도록 변경
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
  
  // ✨ 2. 스크롤 감지 및 추가 데이터 요청 함수
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50 &&
        _hasMore &&
        !_isFetchingMore) {
      if (_addresses.isNotEmpty) {
        // TODO: Address 모델의 ID 필드명(id)이 정확한지 확인해주세요.
        _fetchAddresses(cursorId: _addresses.last.addressId);
      }
    }
  }

  Future<void> _loadAddressesFromStorage() async {
    setState(() => _isLoading = true);
    final storedAddresses = await StorageService().getAddresses();
    if (storedAddresses != null && mounted) {
      setState(() {
        _addresses = storedAddresses;
        _isLoading = false;
      });
    } else {
      // If nothing is in storage, fetch from the network.
      _fetchAddresses();
    }
  }

  Future<void> _fetchAddresses({int? cursorId}) async {
    if (_isFetchingMore) return;

    setState(() {
      if (cursorId == null) _isLoading = true;
      else _isFetchingMore = true;
    });

    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) throw Exception('Token is missing');

      final headers = {'Authorization': 'Bearer $accessToken'};
      final uri = Uri.parse('$baseUrl/address').replace(queryParameters: {
        'size': '10',
        if (cursorId != null) 'cursorId': cursorId.toString(),
      });
      
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true && data['result'] != null) {
          final List<dynamic> addressJson = data['result']['content'];
          final newAddresses = addressJson.map((json) => Address.fromJson(json)).toList();

          if (mounted) {
            setState(() {
              if (cursorId == null) {
                _addresses = newAddresses;
              } else {
                _addresses.addAll(newAddresses);
              }
              if (newAddresses.length < 10) {
                _hasMore = false;
              }
            });
          }
          // 로컬 저장소에도 최신 목록 전체를 저장
          await StorageService().saveAddresses(_addresses);
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching addresses: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFetchingMore = false;
        });
      }
    }
  }
  
  void _navigateToEditScreen(Address address) async {
    // 수정 화면으로 이동하고, 돌아올 때까지 기다립니다.
    final result = await Navigator.pushNamed(
      context,
      '/consumer/mypage/info/edit/address/edit',
      arguments: address,
    );

    // 수정 화면에서 어떤 변경이 있었을 수 있으므로, 돌아오면 목록을 새로고침합니다.
    if (result == true && mounted) {
      _fetchAddresses();
    }
  }

  Future<void> _deleteAddress(Address addressToDelete) async {
    // 1-1. 삭제 확인 모달창을 띄우고 결과를 기다림
    final bool? confirmed = await _showDeleteConfirmDialog();
    if (confirmed != true) return; // '아니오'를 누르면 아무것도 하지 않음

    // 1-2. '예'를 누르면 API 호출
    try {
      final accessToken = await StorageService.getAccessToken();
      if (accessToken == null) throw Exception('Token is missing');

      final headers = {'Authorization': 'Bearer $accessToken'};
      final uri = Uri.parse('$baseUrl/address/delete/${addressToDelete.addressId}');

      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 1-3. API 성공 시, 로컬 리스트에서 해당 주소 제거
        setState(() {
          _addresses.removeWhere((address) => address.addressId == addressToDelete.addressId);
        });
        
        // 1-4. 삭제 성공 모달창 표시
        await _showDeleteSuccessDialog();

      } else {
        throw Exception('Failed to delete address: ${response.body}');
      }
    } catch (e) {
      print('Error deleting address: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    }
  }
  
  // ✨ 2. 삭제 확인 모달창
  Future<bool?> _showDeleteConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('선택하신 배송지를\n정말 삭제하시겠습니까?', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Image.asset('assets/mascot/login_mascot.png', height: 60), // TODO: mascot 이미지 경로 확인
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false), // 아니오
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('아니오', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true), // 예
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6FCF4B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('예'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // ✨ 3. 삭제 성공 모달창
  Future<void> _showDeleteSuccessDialog() {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('삭제되었습니다.', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              Image.asset('assets/mascot/login_mascot.png', height: 60),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(), // 닫기
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6FCF4B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('닫기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 상태바, 화면 크기 변수 고정
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // 시스템 UI 투명
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          ConsumerTopNotchHeader(),

          // 콘텐츠
          Padding(
            padding: EdgeInsets.only(
              top: statusBarHeight + screenHeight * 0.06 + 20,
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              bottom: bottomPadding + 48 + 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 뒤로가기 + 제목
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Image.asset(
                        'assets/icons/goback.png',
                        width: 18,
                        height: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '배송지 관리',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // 주소 리스트
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _addresses.isEmpty
                          ? const Center(child: Text('등록된 배송지가 없습니다.'))
                          // ✨ 4. ListView.separated 수정
                          : ListView.separated(
                              controller: _scrollController, // 컨트롤러 연결
                              padding: EdgeInsets.zero,
                              itemCount: _addresses.length + (_hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _addresses.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                final address = _addresses[index];
                                return _AddressCard(
                                  address: address,
                                  onEdit: () => _navigateToEditScreen(address),
                                  onDelete: () => _deleteAddress(address),
                                );
                              },
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                            ),
                ),
              ],
            ),
          ),
          Positioned(
            left: screenWidth * 0.08,
            right: screenWidth * 0.08,
            // Position the button above the system nav bar with some margin
            bottom: bottomPadding + 20,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.pushNamed(
                    context,
                    '/consumer/mypage/info/edit/address/add',
                  );
                  _fetchAddresses();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6FCF4B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  '배송지 추가',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address.addressName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('${address.recipient} | ${address.phoneNumber}',
              style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Text(
            '${address.address} ${address.detailAddress} [${address.portCode}]',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton(
                onPressed: onEdit, // Connect the callback
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0x3333334B)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('수정', style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onDelete, // Connect the callback
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0x3333334B)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('삭제', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}