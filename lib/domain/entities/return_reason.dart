enum ReturnReason {
  defective('Producto defectuoso'),
  wrongItem('Producto incorrecto'),
  changedMind('Ya no lo necesito'),
  expired('Producto vencido'),
  other('Otro');

  final String label;
  const ReturnReason(this.label);
}
