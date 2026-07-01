enum ApiRoutes {
  login('login'),
  register('register'),
  logout('logout'),
  orders('orders'),
  cashierOrders('cashier/orders'),
  distributionHistory('orders/distribution-history'),
  forDistribution('orders/ready-for-distribution'),
  distributeOrder('orders/{order}/distribute'),
  updateOrder('orders/{order}'),
  cancelOrder('orders/{order}/cancel'),
  updateUser('users/{user}');

  final String path;
  const ApiRoutes(this.path);

  /// Remplace les valeurs dynamiques dans l'URL
  String format(Map<String, dynamic> params) {
    String formattedPath = path;
    params.forEach((key, value) {
      formattedPath = formattedPath.replaceAll(
        '{$key}',
        value != null ? Uri.encodeComponent(value.toString()) : '',
      );
    });
    formattedPath = formattedPath
        .replaceAll(RegExp(r'[?&][^=]+=$'), '')
        .replaceAll(RegExp(r'\?&'), '?')
        .replaceAll(RegExp(r'\?$'), '');

    return formattedPath;
  }
}
