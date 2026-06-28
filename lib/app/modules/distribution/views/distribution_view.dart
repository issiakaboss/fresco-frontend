import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/distribution_controller.dart';

class DistributionView extends GetView<DistributionController> {
  const DistributionView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DistributionView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DistributionView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
