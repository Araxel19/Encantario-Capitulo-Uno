enum CardStatus {
  locked,
  open,
  complete,
}

class CardItem {
  final String id;
  final String title;
  final String description;
  CardStatus status;

  CardItem({
    required this.id,
    required this.title,
    required this.description,
    this.status = CardStatus.locked,
  });
}
