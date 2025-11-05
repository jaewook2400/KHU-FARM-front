import 'package:flutter/material.dart';

class AddProductOptionPage extends StatefulWidget {
  const AddProductOptionPage({super.key});

  @override
  State<AddProductOptionPage> createState() => _AddProductOptionPageState();
}

class _AddProductOptionPageState extends State<AddProductOptionPage> {
  final _titleController = TextEditingController();
  // 중량 세트 데이터 리스트
  final List<Map<String, TextEditingController>> _weightSets = [];

  @override
  void initState() {
    super.initState();
    _addWeightSet(); // 기본 1세트 추가
  }

  // 중량 세트 추가
  void _addWeightSet() {
    setState(() {
      _weightSets.add({
        'weight': TextEditingController(),
        'price': TextEditingController(),
        'stock': TextEditingController(),
      });
    });
  }

  // 중량 세트 제거
  void _removeWeightSet(int index) {
    setState(() {
      _weightSets.removeAt(index);
    });
  }

  // 데이터 저장
  void _saveOption() {
    final Map<String, dynamic> optionList = {};
    final List<Map<String, dynamic>> weightList = [];

    for (var set in _weightSets) {
      final weight = set['weight']!.text.trim();
      final price = set['price']!.text.trim();
      final stock = set['stock']!.text.trim();

      if (weight.isEmpty || price.isEmpty || stock.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모든 항목을 입력해주세요.')),
        );
        return;
      }

      weightList.add({
        'weight': weight,
        'price': price,
        'stock': stock,
      });
    }

    optionList['weight'] = weightList;

    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('상품 제목을 입력해주세요.')),
      );
      return;
    }
    optionList['title'] = _titleController.text.trim();

    Navigator.pop(context, optionList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('옵션 1 설정하기'),
        backgroundColor: Colors.green.shade600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: '상품 제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _weightSets.length,
                itemBuilder: (context, index) {
                  final set = _weightSets[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '상품 ${index + 1}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            if (_weightSets.length > 1)
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _removeWeightSet(index),
                                color: Colors.redAccent,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: set['weight'],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '상품 중량 (수량 1개)',
                            suffixText: 'kg',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: set['price'],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '상품 가격',
                            suffixText: '원',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: set['stock'],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '준비된 재고',
                            suffixText: '박스',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _addWeightSet,
              icon: const Icon(Icons.add),
              label: const Text('중량 추가하기'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green.shade700,
                side: BorderSide(color: Colors.green.shade400),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveOption,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('다음'),
            ),
          ],
        ),
      ),
    );
  }
}
