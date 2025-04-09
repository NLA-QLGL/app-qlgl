class Transaction {
  final String id;
  final String title;
  final String date;
  final double amount;
  final String status;

  Transaction({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
  });

  static List<Transaction> getSampleTransactions() {
    return [
      Transaction(
        id: '1',
        title: 'Giặt quần áo',
        date: '17/01/2024 10:00',
        amount: 50000,
        status: 'Thành công',
      ),
      Transaction(
        id: '2',
        title: 'Giặt chăn',
        date: '17/01/2024 10:00',
        amount: 55000,
        status: 'Đang giặt',
      ),
      Transaction(
        id: '3',
        title: 'Giặt giày',
        date: '17/01/2024 10:00',
        amount: 150000,
        status: 'Thành công',
      ),
    ];
  }

  static Map<String, List<Transaction>> getGroupedTransactions() {
    return {
      'Tháng 01/2024': [
        Transaction(
          id: '1',
          title: 'Giặt quần áo',
          date: '17/01/2024 10:00',
          amount: 50000,
          status: 'Thành công',
        ),
        Transaction(
          id: '2',
          title: 'Giặt chăn',
          date: '15/01/2024 10:00',
          amount: 55000,
          status: 'Đang giặt',
        ),
        Transaction(
          id: '3',
          title: 'Giặt giày',
          date: '12/01/2024 10:00',
          amount: 150000,
          status: 'Thành công',
        ),
      ],
      'Tháng 12/2023': [
        Transaction(
          id: '4',
          title: 'Giặt quần áo',
          date: '31/12/2023 10:00',
          amount: 50000,
          status: 'Thành công',
        ),
        Transaction(
          id: '5',
          title: 'Giặt chăn',
          date: '25/12/2023 12:00',
          amount: 55000,
          status: 'Đang giặt',
        ),
        Transaction(
          id: '6',
          title: 'Giặt giày',
          date: '10/12/2023 10:00',
          amount: 150000,
          status: 'Thành công',
        ),
        Transaction(
          id: '7',
          title: 'Giặt quần áo',
          date: '05/12/2023 08:00',
          amount: 150000,
          status: 'Thành công',
        ),
      ],
      'Tháng 11/2023': [
        Transaction(
          id: '8',
          title: 'Giặt quần áo',
          date: '29/11/2023 10:00',
          amount: 50000,
          status: 'Thành công',
        ),
        Transaction(
          id: '9',
          title: 'Giặt chăn',
          date: '25/11/2023 12:00',
          amount: 55000,
          status: 'Đang giặt',
        ),
        Transaction(
          id: '10',
          title: 'Giặt giày',
          date: '10/11/2023 10:00',
          amount: 150000,
          status: 'Thành công',
        ),
      ],
    };
  }
}