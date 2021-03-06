import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ds_loyalty_user/app/home/models/offer.dart';
import 'package:ds_loyalty_user/common_widgets/show_alert_dialog.dart';
import 'package:ds_loyalty_user/common_widgets/show_exception_alert.dart';
import 'package:ds_loyalty_user/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditOffer extends StatefulWidget {
  const EditOffer({Key key, @required this.database, this.offer}) : super(key: key);
  final Database database;
  final Offer offer;

  static Future<void> show(BuildContext context, {Offer offer}) async {
    final database = Provider.of<Database>(context, listen: false);
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EditOffer(
        database: database,
        offer: offer,
      ),
      fullscreenDialog: true,
    ));
  }

  @override
  _EditOfferState createState() => _EditOfferState();
}

class _EditOfferState extends State<EditOffer> {
  final _formKey = GlobalKey<FormState>();

  String _name;
  int _pointCost;

  @override
  void initState() {
    super.initState();
    if (widget.offer != null) {
      _name = widget.offer.name;
      _pointCost = widget.offer.pointCost;
    }
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> _submit() async {
    if (_validateAndSaveForm()) {
      try {
        final offers = await widget.database.offersStream().first;
        final allNames = offers.map((offer) => offer.name).toList();
        if (widget.offer != null) {
          allNames.remove(widget.offer.name);
        }
        if (allNames.contains(_name)) {
          showAlertDialog(context, title: 'Title already used', content: 'Enter different title', defaultActionText: 'Ok');
        } else {
          final id = widget.offer?.id ?? documentTimestamp();
          final offer = Offer(id: id, name: _name, pointCost: _pointCost);
          await widget.database.setOffer(offer);
          Navigator.of(context).pop();
        }
      } on FirebaseException catch (e) {
        showExceptionAlert(
          context,
          title: 'Operation failed',
          exception: e,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        title: Text(widget.offer == null ? 'New offer' : 'Edit offer'),
        actions: [
          FlatButton(
              onPressed: _submit,
              child: Text(
                'Save',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ))
        ],
      ),
      body: _buildContents(),
      backgroundColor: Colors.black87,
    );
  }

  Widget _buildContents() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _buildFormChildren(),
        ));
  }

  List<Widget> _buildFormChildren() {
    return [
      TextFormField(
        autofocus: true,
        initialValue: _name,
        decoration: InputDecoration(
          labelText: 'Offer name',
        ),
        validator: (value) => value.isNotEmpty ? null : 'Name can\'t be empty',
        onSaved: (value) => _name = value,
        textInputAction: TextInputAction.next,
      ),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Cost',
        ),
        initialValue: _pointCost != null ? '$_pointCost' : null,
        validator: (value) => value.isNotEmpty ? null : 'Cost can\'t be empty',
        onSaved: (value) => _pointCost = int.tryParse(value) ?? 0,
        textInputAction: TextInputAction.done,
        onEditingComplete: _submit,
        keyboardType: TextInputType.numberWithOptions(
          signed: false,
          decimal: false,
        ),
      ),
    ];
  }
}
