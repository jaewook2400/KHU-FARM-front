import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:khu_farm/model/address.dart';
import 'package:khu_farm/constants.dart';
import 'package:khu_farm/services/storage_service.dart';


class RetailerAddressListScreen extends StatefulWidget {
  const RetailerAddressListScreen({super.key});

  @override
  State<RetailerAddressListScreen> createState() =>
      _RetailerAddressListScreenState();
}

class _RetailerAddressListScreenState extends State<RetailerAddressListScreen> {
  List<Address> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddressesFromStorage();
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

  Future<void> _fetchAddresses() async {
    if (!mounted) setState(() => _isLoading = true);
    
    final accessToken = await StorageService.getAccessToken();
    if (accessToken == null) {
      setState(() => _isLoading = false);
      return;
    }

    final headers = {'Authorization': 'Bearer $accessToken'};
    final uri = Uri.parse('$baseUrl/address');

    try {
      final response = await http.get(uri, headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['isSuccess'] == true && data['result'] != null) {
          final List<dynamic> addressJson = data['result']['content'];
          final newAddresses = addressJson.map((json) => Address.fromJson(json)).toList();
          
          // Save the newly fetched addresses to storage
          await StorageService().saveAddresses(newAddresses);

          if (mounted) {
            setState(() {
              _addresses = newAddresses;
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching addresses: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  void _navigateToEditScreen(Address address) {
    Navigator.pushNamed(
      context,
      '/retailer/mypage/info/edit/address/edit',
      arguments: address, // Pass the full address object
    ).then((_) {
      // Refresh the list when returning from the edit screen
      _fetchAddresses();
    });
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
          // 노치 배경
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: statusBarHeight + screenHeight * 0.06,
            child: Image.asset('assets/notch/morning.png', fit: BoxFit.cover),
          ),
          Positioned(
            top: 0,
            right: 0,
            height: statusBarHeight * 1.2,
            child: Image.asset(
              'assets/notch/morning_right_up_cloud.png',
              fit: BoxFit.cover,
              alignment: Alignment.topRight,
            ),
          ),
          Positioned(
            top: statusBarHeight,
            left: 0,
            height: screenHeight * 0.06,
            child: Image.asset(
              'assets/notch/morning_left_down_cloud.png',
              fit: BoxFit.cover,
              alignment: Alignment.topRight,
            ),
          ),

          Positioned(
            top: statusBarHeight,
            height: statusBarHeight + screenHeight * 0.02,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/retailer/main',
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'KHU:FARM',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/retailer/notification/list',
                        );
                      },
                      child: Image.asset(
                        'assets/top_icons/notice.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/retailer/dib/list');
                      },
                      child: Image.asset(
                        'assets/top_icons/dibs.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/retailer/cart/list');
                      },
                      child: Image.asset(
                        'assets/top_icons/cart.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

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
                          : ListView.separated( // Using ListView.separated for better spacing
                              padding: EdgeInsets.zero,
                              itemCount: _addresses.length,
                              itemBuilder: (context, index) {
                                final address = _addresses[index];
                                return _AddressCard(
                                  // --- This is updated ---
                                  address: address, // Pass the full address object
                                  onEdit: () => _navigateToEditScreen(address),
                                  onDelete: () {
                                    // TODO: Implement delete logic
                                  },
                                  // --- End of update ---
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12), // Space between cards
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
                    '/retailer/mypage/info/edit/address/add',
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
          // Row(
          //   children: [
          //     OutlinedButton(
          //       onPressed: onEdit, // Connect the callback
          //       style: OutlinedButton.styleFrom(
          //         side: const BorderSide(color: Color(0x3333334B)),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(30),
          //         ),
          //       ),
          //       child: const Text('수정', style: TextStyle(color: Colors.black)),
          //     ),
          //     const SizedBox(width: 8),
          //     OutlinedButton(
          //       onPressed: onDelete, // Connect the callback
          //       style: OutlinedButton.styleFrom(
          //         side: const BorderSide(color: Color(0x3333334B)),
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(30),
          //         ),
          //       ),
          //       child: const Text('삭제', style: TextStyle(color: Colors.black)),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}