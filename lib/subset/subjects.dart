import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:midterm_mobile/constants.dart';
import '../classes/subject.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../main/login.dart';
import '../main/registration.dart';
import 'cartscreen.dart';

class Subjects extends StatefulWidget {
    final User user;

  const Subjects({Key? key, required this.user}) : super(key: key);
  

  @override
  State<Subjects> createState() => _SubjectsState();
}

class _SubjectsState extends State<Subjects> {
  List<Subject> subjectlist = <Subject>[];
  String titlecenter = "No Subject";
  late double screenHeight, screenWidth, resWidth;
  var _tapPosition;
  var numofpage, curpage = 1;
  var color;

  TextEditingController searchController = TextEditingController();
  String search = "";
  String dropdownvalue = '10 weeks';
  var types = [
    'All',
    '10 weeks',
    '12 weeks',
    '14 weeks',
    '22 weeks',
    '32 weeks',
  ];

  @override
  void initState() {
    super.initState();
    _loadSubjects(1, search, "All");
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = screenWidth;
      //rowcount = 2;
    } else {
      resWidth = screenWidth * 0.75;
      //rowcount = 3;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 3, 195, 96),
        title: const Text('Subjects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _loadSearchDialog();
            },
          ),
          TextButton.icon(onPressed: () async {
            if(widget.user.email == "guest@gmail.com"){
              _loadOptions();
            }else{
              await Navigator.push(context,MaterialPageRoute(builder: (content)=> CartScreen(user:widget.user))
               );
               _loadSubjects(1, search,"All");
                _loadMyCart();
          
            }
            },
            icon:const Icon(Icons.shopping_cart,
          color: Colors.white),
          label: Text(widget.user.cart.toString(),
          style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: subjectlist.isEmpty
          ? Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Column(children: [
                Center(
                    child: Text(titlecenter,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: types.map((String char) {
                      return Padding(
                          padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                          child: ElevatedButton(
                            child: Text(char),
                            onPressed: () {
                              _loadSubjects(1, "", char);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green, // Background color
                            ),
                          ));
                    }).toList(),
                  ),
                ),
              ]),
            )
          : Column(children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text("Subject Avaliable",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: types.map((String char) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                      child: ElevatedButton(
                        child: Text(char),
                        onPressed: () {
                          _loadSubjects(1, "", char);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green, // Background color
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                  child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: (1 / 1),
                children: List.generate(subjectlist.length, (index) {
                  return InkWell(
                      splashColor: Colors.green,
                      onLongPress: () => {_loadDetails(index)},
                      onTapDown: _storePosition,
                      child: Card(
                          child: Column(
                        children: [
                          Flexible(
                            flex: 6,
                            child: CachedNetworkImage(
                              imageUrl: CONSTANTS.server +
                                  "/mytutor/mobile/assets/courses" +
                                  subjectlist[index].subjectId.toString() +
                                  '.png',
                              fit: BoxFit.cover,
                              width: resWidth,
                              placeholder: (context, url) =>
                                  const LinearProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                          Flexible(
                            flex: 4,
                            child: Column(
                              children: [
                                Text(subjectlist[index].subjectName.toString()),
                                Text(
                                    subjectlist[index].subjectPrice.toString()),
                                Text(subjectlist[index]
                                    .subjectRating
                                    .toString()),
                                Text(subjectlist[index].studyPlan.toString()),
                              ],
                            ),
                          ),
                            Expanded(
                              flex:3,
                              child: IconButton(onPressed:() {
                                _addtocartDialog(index);
                              },
                              icon: const Icon(Icons.add
                            )
                          ),
                            ),
                        ],
                      )));
                }),
              )),
              SizedBox(
                height: 30,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: numofpage,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    if ((curpage - 1) == index) {
                      color = Colors.green;
                    } else {
                      color = Colors.black;
                    }
                    return SizedBox(
                      width: 40,
                      child: TextButton(
                          onPressed: () =>
                              {_loadSubjects(index + 1, "", "All")},
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(color: color),
                          )),
                    );
                  },
                ),
              ),
            ]),
    );
  }

  void _loadSubjects(int pageno, String _search, String _type) {
    curpage = pageno;
    numofpage ?? 1;
   // ProgressDialog pd = ProgressDialog (context: context);
   // pd.show(msg: 'Loading ...',max:100);
    http.post(
        Uri.parse(CONSTANTS.server + "/mytutor/mobile/php/loadsubjects.php"),
        body: {
          'pageno': pageno.toString(),
          'search': _search,
          'type': _type,
        }).timeout(const Duration(seconds: 5),
        onTimeout:(){
          return http.Response('Error',408);
        }).timeout(const Duration(seconds:5),
        onTimeout:(){
          titlecenter = "Timeout Plaese rentry again later";
          return http.Response('Error',408);
        }).then((response) {
          print(response.body);
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        var extractdata = jsondata['data'];
        numofpage = int.parse(jsondata['numofpage']);
        if (extractdata['subjects'] != null) {
          subjectlist = <Subject>[];
          extractdata['subjects'].forEach((v) {
            subjectlist.add(Subject.fromJson(v));
          });
        }
      } else {
        titlecenter = "No subjects Available";
        subjectlist.clear();
      }
      setState(() {});
    });
    //pd.close();
  }

  void _loadSearchDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, StateSetter setState) {
              return AlertDialog(
                title: const Text(
                  "Search ",
                ),
                content: SizedBox(
                  height: screenHeight / 5,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                            labelText: 'Search',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        height: 60,
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(5.0))),
                        child: DropdownButton(
                          value: dropdownvalue,
                          underline: const SizedBox(),
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: types.map((String items) {
                            return DropdownMenuItem(
                              value: items,
                              child: Text(items),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              dropdownvalue = newValue!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      search = searchController.text;
                      Navigator.of(context).pop();
                      _loadSubjects(1, search, "All");
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green, // Background color
                    ),
                    child: const Text("Search"),
                  )
                ],
              );
            },
          );
        });
  }

  _loadDetails(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: const Text(
              "Subject Details",
              style: TextStyle(),
            ),
            content: SingleChildScrollView(
                child: Column(
              children: [
                CachedNetworkImage(
                  imageUrl: CONSTANTS.server +
                      "/mytutor/mobile/assets/courses" +
                      subjectlist[index].subjectId.toString() +
                      '.png',
                  fit: BoxFit.cover,
                  width: resWidth,
                  placeholder: (context, url) =>
                      const LinearProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                Text(
                  subjectlist[index].subjectName.toString(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Description: \n" +
                      subjectlist[index].subjectDescription.toString()),
                  Text("Price: RM \n" +
                      subjectlist[index].subjectPrice.toString()),
                  Text(
                      "Rating: " + subjectlist[index].subjectRating.toString()),
                  Text(
                      "Study Plan: " + subjectlist[index].studyPlan.toString()),
                ])
              ],
            )),
           
          
          actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      _addtocartDialog(index);
                    },
                    icon: Icon(
                      Icons.shopping_cart,
                      color: Colors.black,
                      size: 24.0,
                    ),
                    label: Text(
                      'Add to cart',
                      style: TextStyle(
                        color: Colors.black, //for text color
                      ),
                    ),
                  ),
                ],
              ),
            ]);
        });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }
  
  void _addtocartDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: const Text(
            "Add to cart?",
            style: TextStyle(),
          ),
          content: const Text("Are you sure?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                _addtoCart(index);
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
 
  void _addtoCart(int index) {
     http.post(
        Uri.parse(CONSTANTS.server + "/mytutor/mobile/php/insertsub.php"),
        body: {
          "user_email": widget.user.email.toString(),
          "subjectid": subjectlist[index].subjectId.toString(),
        }).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        return http.Response(
            'Error', 408); // Request Timeout response status code
      },
    ).then((response) {
      print(response.body);
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        print(jsondata['data']['carttotal'].toString());
        setState(() {
          widget.user.cart = jsondata['data']['carttotal'].toString();
        });
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      } else {
        Fluttertoast.showToast(
            msg: "You already added this course to cart.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      }
    });
  }


   _loadOptions() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: const Text(
              "Please select",
              style: TextStyle(),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(onPressed: _onLogin, child: const Text("Login")),
                ElevatedButton(
                    onPressed: _onRegister, child: const Text("Register")),
              ],
            ),
          );
        });
  }


   void _onLogin() {
    Navigator.push(
        context, MaterialPageRoute(builder: (content) => const Loginscreen()));
  }


  void _onRegister() {
    Navigator.push(context,
        MaterialPageRoute(builder: (content) => const Registrationscreen()));
  }

   void _loadMyCart() {
    http.post(
        Uri.parse(CONSTANTS.server + "/mytutor/mobile/php/load_mycartqty.php"),
        body: {
          "email": widget.user..toString(),
        }).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        return http.Response(
            'Error', 408); // Request Timeout response status code
      },
    ).then((response) {
      print(response.body);
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        print(jsondata['data']['carttotal'].toString());
        setState(() {
          widget.user.cart = jsondata['data']['carttotal'].toString();
        });
      }
    });
  }
    }
    