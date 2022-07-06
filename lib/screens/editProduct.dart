import 'package:e_shop/providers/products.dart';
import 'package:e_shop/widgets/Loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const String routeName = '/edit-product';
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  String _title = '';
  String _description = '';
  String _price = '';
  String _imageUrl = '';
  bool _loading = false;

  bool _init = false;

  void _saveForm(addProduct, String? productId) {
    final isValidated = _formKey.currentState?.validate();
    if (!isValidated!) {
      return;
    }
    _formKey.currentState?.save();
    setState(() {
      _loading = true;
    });
    addProduct(Product(
            id: productId ?? DateTime.now().toString(),
            title: _title,
            description: _description,
            price: num.parse(_price),
            imageUrl: _imageUrl))
        .then((isSuccess) => isSuccess ? Navigator.of(context).pop() : null)
        .whenComplete(() {
      setState(
        () {
          _loading = false;
        },
      );
    });
  }

  @override
  void didChangeDependencies() {
    if (!_init) {
      final productId = ModalRoute.of(context)!.settings.arguments;
      if (productId != null) {
        final product = Provider.of<Products>(context, listen: false)
            .items
            .firstWhere((element) => element.id == productId);
        _title = product.title;
        _description = product.description;
        _price = product.price.toString();
        _imageUrl = product.imageUrl;
      }
    }
    _init = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<Products>(context);
    final productId = ModalRoute.of(context)!.settings.arguments as String?;
    return Scaffold(
      appBar: AppBar(
        title: Text(productId == null ? 'Add Product' : 'Edit Products'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      label: Text('Title'),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 5) {
                        return 'Please enter valid title';
                      }
                      return null;
                    },
                    autofocus: true,
                    initialValue: _title,
                    textInputAction: TextInputAction.next,
                    onSaved: (text) {
                      setState(() {
                        _title = text ?? '';
                      });
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      label: Text('Description'),
                    ),
                    maxLines: null,
                    initialValue: _description,
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value == null || value.length < 10) {
                        return 'Please enter valid description';
                      }
                      return null;
                    },
                    onSaved: (text) {
                      setState(() {
                        _description = text ?? '';
                      });
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      label: Text('Price'),
                    ),
                    initialValue: _price,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null) {
                        return 'Please enter price';
                      }
                      final parsedPrice = num.tryParse(value);
                      if (parsedPrice == null || parsedPrice < 0) {
                        return 'Please enter valid price';
                      }
                      return null;
                    },
                    onSaved: (text) {
                      setState(() {
                        _price = text ?? '';
                      });
                    },
                  ),
                  // GestureDetector(
                  //   onTap: () async {
                  //     final DateTime? picked = await showDatePicker(
                  //       context: context,
                  //       initialDate: DateTime.now(),
                  //       firstDate: DateTime(2019, 8),
                  //       lastDate: DateTime(2100),
                  //     );
                  //     print(picked);
                  //   },
                  //   child: AbsorbPointer(
                  //     child: TextFormField(
                  //       decoration: const InputDecoration(
                  //         label: Text('Product manufactured at'),
                  //       ),
                  //       keyboardType: TextInputType.datetime,
                  //     ),
                  //   ),
                  // ),

                  // Container(
                  //   height: 200,
                  //   margin: const EdgeInsets.only(top: 12),
                  //   child: DropdownButtonFormField(
                  //     items: const [
                  //       DropdownMenuItem(child: Text('Value 1'), value: 0),
                  //       DropdownMenuItem(
                  //         child: Text('Value 2'),
                  //         value: 1,
                  //       ),
                  //       DropdownMenuItem(child: Text('Value 3'), value: 2),
                  //       DropdownMenuItem(child: Text('Value 4'), value: 3),
                  //       DropdownMenuItem(child: Text('Value 5'), value: 4),
                  //       DropdownMenuItem(child: Text('Value 6'), value: 5),
                  //       DropdownMenuItem(
                  //         child: Text('Value 7'),
                  //         value: 6,
                  //       ),
                  //       DropdownMenuItem(child: Text('Value 8'), value: 7),
                  //       DropdownMenuItem(child: Text('Value 9'), value: 8),
                  //       DropdownMenuItem(child: Text('Value 10'), value: 9),
                  //     ],
                  //     menuMaxHeight: 200,
                  //     onChanged: (dynamic value) {
                  //       print(value);
                  //     },
                  //     decoration: InputDecoration(
                  //       labelText: 'Dropdown',
                  //       // contentPadding: EdgeInsets.fromLTRB(12, 10, 20, 20),
                  //       border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(10.0)),
                  //     ),
                  //   ),
                  // ),
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black, width: 1)),
                          width: 75,
                          height: 75,
                          child: Image.network(
                            _imageUrl,
                            height: 75,
                            width: 75,
                            errorBuilder: (_, __, ___) {
                              return const Text('Enter url');
                            },
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Image URL'),
                            ),
                            initialValue: _imageUrl,
                            onChanged: (text) {
                              setState(() {
                                _imageUrl = text;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please enter image Url';
                              }
                              if (!value.startsWith('https') ||
                                  !value.startsWith('http')) {
                                return 'please enter valid image url';
                              }
                            },
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _saveForm(
                                productId != null
                                    ? products.editProduct
                                    : products.addProduct,
                                productId),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(top: 12),
                    child: TextButton(
                      onPressed: () => _saveForm(
                          productId != null
                              ? products.editProduct
                              : products.addProduct,
                          productId),
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Loader(
            isFullScreen: true,
            isfullScreenWithBackgroundTransparent: true,
            isLoading: _loading,
          )
        ],
      ),
    );
  }
}
