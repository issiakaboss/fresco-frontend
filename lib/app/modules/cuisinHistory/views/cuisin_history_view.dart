import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/cuisin_history_controller.dart';

class CuisinHistoryView extends GetView<CuisinHistoryController> {
  const CuisinHistoryView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CuisinHistoryView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'CuisinHistoryView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
