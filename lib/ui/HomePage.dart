import 'package:flutter/material.dart';
import 'package:sexto_projeto/ui/ContactPage.dart';
import '../helpers/contacts_helpers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

enum OrderOptions {
  orderaz,
  orderza
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();

  

  @override
  void initState(){
    super.initState();

    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: ( context ) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordenar de A-Z'),
                value: OrderOptions.orderaz,
              ),
              const PopupMenuItem<OrderOptions>(
                child: Text('Ordenar de Z-A'),
                value: OrderOptions.orderza,
              ),
            ],
            onSelected: _orderList,
          )
        ],
        title: Text(
          'Contatos',
          style: TextStyle(color: Colors.white, fontSize: 18.0),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showContactPage();
        },
        child: Icon(
          Icons.add
        ),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: contacts.length,
        itemBuilder:_contactCard
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index){
    return GestureDetector(
      onTap: (){
        _showOptions( context , index );
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: contacts[index].img != null ? 
                    FileImage(File(contacts[index].img)) :
                    AssetImage("images/user.png")
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left : 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      contacts[index].name ?? "",
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      contacts[index].email ?? "",
                      style: TextStyle(fontSize: 16.0),
                      ),
                    Text(contacts[index].phone ?? "",
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showOptions( BuildContext context, int index ){

        showModalBottomSheet(context: context, builder:( context ){
          return BottomSheet(
            onClosing: (){},
            builder:( context ){
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        onPressed: (){
                          launch("tel:${contacts[index].phone}");
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Ligar',
                          style: TextStyle(
                            color : Colors.red,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        onPressed: (){
                          Navigator.pop(context);
                          _showContactPage(contact : contacts[index]);
                        },
                        child: Text(
                          'Editar',
                          style: TextStyle(
                            color : Colors.red,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: FlatButton(
                        onPressed: (){
                          setState((){
                            Navigator.pop(context);
                            helper.deleteContact(contacts[index].id);
                          });
                        },
                        child: Text(
                          'Excluir',
                          style: TextStyle(
                            color : Colors.red,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        });

  }

  void _orderList(OrderOptions result){
    switch( result ){
      case OrderOptions.orderaz:
        contacts.sort( ( a, b ) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort( ( a, b ) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState((){});
  }

  void _showContactPage({Contact contact}) async{
    final recContact = await Navigator.push(context, 
    MaterialPageRoute(
      builder: ( context ) => ContactPage(contact : contact)
    ));
    if( recContact != null ){
      if( contact != null ){
        await helper.updateContact(recContact);
      }else{
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }else{

    }
  }

  void _getAllContacts(){
    helper.getAllContacts().then(( list ){
      setState((){
        contacts = list;
      });
    });
  }

}