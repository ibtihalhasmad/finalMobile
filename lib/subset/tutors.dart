import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../classes/tutor.dart';
import '../constants.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Tutors extends StatefulWidget {
  const Tutors({Key? key}) : super(key: key);

  @override
  State<Tutors> createState() => _TutorsState();
}

class _TutorsState extends State<Tutors> {
  List<Tutor> tutorlist = <Tutor>[];
  String titlecenter = "No Tutors";
  late double screenHeight, screenWidth, resWidth;
  var _tapPosition;
  var numofpage, curpage = 1;
  var color;

  TextEditingController searchController = TextEditingController();
  String search = "";
  String dropdownvalue = 'In English';
  var types = [
    'All',
    'In English',
    'In Spanish',
    'In Hindi',
    'In Malay',
  ];

  @override
  void initState() {
    super.initState();
    _loadTutors(1, search, "All");
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth <= 600) {
      resWidth = screenWidth;
    } else {
      resWidth = screenWidth * 0.75;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 3, 195, 96),
        title: const Text('Tutors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _loadSearchDialog();
            },
          )
        ],
      ),
      body: tutorlist.isEmpty
          ? Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Column(children: [
                Center(
                  child: Text(titlecenter,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
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
                            _loadTutors(1, "", char);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green, // Background color
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ]),
            )
          : Column(children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Text("Tutor Available",
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
                          _loadTutors(1, "", char);
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
                children: List.generate(tutorlist.length, (index) {
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
                                  "/mytutor/mobile/assets/tutors" +
                                  tutorlist[index].tutorId.toString() +
                                  '.jpg',
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
                                Text(tutorlist[index].tutorName.toString()),
                                Text(tutorlist[index].tutorPhone.toString()),
                                Text(tutorlist[index].tutorEmail.toString()),
                                Text(tutorlist[index]
                                    .tutorDescription
                                    .toString()),
                                Text(tutorlist[index].tutorLanguage.toString()),
                              ],
                            ),
                          )
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
                          onPressed: () => {_loadTutors(index + 1, "", "All")},
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

  void _loadTutors(int pageno, String _search, String _type) {
    curpage = pageno;
    numofpage ?? 1;
    http.post(
        Uri.parse(CONSTANTS.server + "/mytutor/mobile/php/loadtutors.php"),
        body: {
          'pageno': pageno.toString(),
          'search': _search,
          'type': _type
        }).then((response) {
      var jsondata = jsonDecode(response.body);
      if (response.statusCode == 200 && jsondata['status'] == 'success') {
        var extractdata = jsondata['data'];
        numofpage = int.parse(jsondata['numofpage']);
        if (extractdata['Tutors'] != null) {
          tutorlist = <Tutor>[];
          extractdata[' Tutors'].forEach((v) {
            tutorlist.add(Tutor.fromJson(v));
          });
        }
      } else {
        titlecenter = "No Tutors Available";
        tutorlist.clear();
      }
      setState(() {});
    });
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
                      _loadTutors(1, search, "All");
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
                      "/mytutor/mobile/assets/tutors" +
                      tutorlist[index].tutorId.toString() +
                      '.jpg',
                  fit: BoxFit.cover,
                  width: resWidth,
                  placeholder: (context, url) =>
                      const LinearProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                Text(
                  tutorlist[index].tutorName.toString(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Name: \n" + tutorlist[index].tutorName.toString()),
                  Text("Description: \n" +
                      tutorlist[index].tutorDescription.toString()),
                  Text("Description: \n" +
                      tutorlist[index].tutorPhone.toString()),
                  Text("Email: " + tutorlist[index].tutorEmail.toString()),
                  Text(
                      "Language: " + tutorlist[index].tutorLanguage.toString()),
                ])
              ],
            )),
            actions: [
              TextButton(
                child: const Text(
                  "Close",
                  style: TextStyle(),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }
}
