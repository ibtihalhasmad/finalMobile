class Cart {
  String? cartid;
  String? sbname;
  String? price;
  String? sbsession;
  String? cartqty;
  String? sbid;
  String? pricetotal;

  Cart(
      {this.cartid,
      this.sbname,
      this.price,
      this.sbsession,
      this.cartqty,
      this.sbid,
      this.pricetotal});

  Cart.fromJson(Map<String, dynamic> json) {
    cartid = json['cartid'];
    sbname = json['sbname'];
    price = json['price'];
    sbsession = json['sbsession'];
    cartqty = json['cartqty'];
    sbid = json['sbid'];
    pricetotal = json['pricetotal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cartid'] = cartid;
    data['sbname'] = sbname;
    data['price'] = price;
    data['sbsession'] = sbsession;
    data['cartqty'] = cartqty;
    data['sbid'] = sbid;
    data['pricetotal'] = pricetotal;
    return data;
  }
}