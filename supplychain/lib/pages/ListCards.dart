import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:supplychain/services/DatabaseService.dart';
import 'package:supplychain/services/functions.dart';
import 'package:supplychain/services/supplyController.dart';
import 'package:supplychain/utils/AlertBoxes.dart';
import 'package:supplychain/utils/AppTheme.dart';
import 'package:supplychain/utils/constants.dart';
import 'package:supplychain/utils/supply.dart';

class ListCard {
  static Future<dynamic> userListCard(
      BuildContext context, List users, String? title, String supplyId) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return UserListCard(
            users: users,
            title: title,
            supplyId: supplyId,
          );
        });
  }

  static Future<dynamic> bidderListCard(
      BuildContext context, Map bidders, String? title) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return BidderListCard(
            bidders: bidders,
            title: title,
          );
        });
  }

  static Future<dynamic> supplyListCard(
      BuildContext context, String? title) async {
    return showGeneralDialog(
        context: context,
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          var curve = Curves.easeInOut.transform(animation.value);
          return ScaleTransition(
            scale: animation,
            alignment: Alignment.bottomCenter,
            child: child,
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          return SupplyListCard(
            context: context,
            title: title,
          );
        });
  }

  static Future<dynamic> userSupplyListCard(BuildContext context, String? title,
      {required var supplyList}) async {
    return showGeneralDialog(
        context: context,
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          var curve = Curves.easeInOut.transform(animation.value);
          return ScaleTransition(
            scale: animation,
            alignment: Alignment.bottomCenter,
            child: child,
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          return UserSupplyListCard(
            context: context,
            supplyList: supplyList,
            title: title,
          );
        });
  }
}

class UserSupplyListCard extends StatefulWidget {
  final String? _title;
  final BuildContext _context;
  final _supplyList;
  const UserSupplyListCard(
      {super.key,
      required BuildContext context,
      required var supplyList,
      required String? title})
      : _title = title,
        _supplyList = supplyList,
        _context = context;

  @override
  State<UserSupplyListCard> createState() => _UserSupplyListCardState();
}

class _UserSupplyListCardState extends State<UserSupplyListCard> {
  late String title;
  late var supplyList;
  late BuildContext context;
  bool isFirstTime = true;
  late SupplyController supplyController;
  late List<Supply> toCreateSupplyList = [];
  late List<String> addedList = [];
  late TextStyle titleTextStyle;
  late TextStyle nameTextStyle;
  late TextStyle boldTextStyle;
  late TextStyle mainTextStyle;
  String fontName = 'roboto';

  @override
  void initState() {
    title = widget._title!;
    supplyList = widget._supplyList;
    context = widget._context;
    initFontStyle();
    super.initState();
  }

  void getSuppliesReadyToBuy() async {
    toCreateSupplyList.clear();
    addedList.clear();
    for (var supplyId in supplyList) {
      Supply s = await supplyController.getSupplyByID(BigInt.parse(supplyId));
      if (userType == insuranceAuthority) {
        if (s.isInsuranceAdded) {
          addedList.add(supplyId);
        }
      } else if (userType == transportAuthority) {
        if (s.isTransporterAdded) {
          addedList.add(supplyId);
        }
      }

      toCreateSupplyList.add(s);
    }
    print("Supplies : ${toCreateSupplyList.toString()}");
    print("Added Supplies : ${addedList.toString()}");
  }

  void initFontStyle() {
    titleTextStyle = TextStyle(
        fontFamily: fontName,
        color: Colors.grey.shade700,
        fontWeight: FontWeight.bold,
        fontSize: 18,
        decoration: TextDecoration.none);
    nameTextStyle = TextStyle(
        color: AppTheme.primaryColor,
        fontFamily: fontName,
        fontWeight: FontWeight.bold,
        fontSize: 17,
        decoration: TextDecoration.none);
    boldTextStyle = TextStyle(
        color: Colors.grey.shade800,
        fontFamily: fontName,
        fontSize: 15,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.none);
    mainTextStyle = TextStyle(
        fontFamily: fontName,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Colors.grey.shade700,
        decoration: TextDecoration.none);
  }

  @override
  Widget build(BuildContext context) {
    supplyController = Provider.of<SupplyController>(context, listen: true);
    if (isFirstTime) {
      getSuppliesReadyToBuy();
      isFirstTime = false;
    }

    return Container(
      margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.1,
          bottom: MediaQuery.of(context).size.height * 0.08),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.grey.shade300),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Spacer(),
              Text(
                title,
                style: titleTextStyle,
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(90),
                      color: AppTheme.primaryColor),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Divider(
              color: Colors.grey.shade700,
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10),
            height: MediaQuery.of(context).size.height * 0.66,
            child: toCreateSupplyList.isEmpty
                ? Center(
                    child: Text(
                      "No Ongoing Supplies found !!",
                      style: boldTextStyle,
                    ),
                  )
                : ListView.builder(
                    itemCount: toCreateSupplyList.length,
                    itemBuilder: (context, index) {
                      Supply supply = toCreateSupplyList[index];

                      return Container(
                        height: MediaQuery.of(context).size.height * .25,
                        margin: EdgeInsets.only(bottom: 20),
                        padding: EdgeInsets.only(right: 15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Container(
                                //container for green border
                                width: 5,
                                height:
                                    MediaQuery.of(context).size.height * .25,
                                decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(90),
                                        bottomLeft: Radius.circular(90)))),
                            Container(
                              padding: EdgeInsets.only(left: 15, top: 10),
                              width: MediaQuery.of(context).size.width * 0.82,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "ID : ${supply.id}",
                                        style: nameTextStyle,
                                      ),
                                      Icon(
                                        Icons.info_outline_rounded,
                                        color: AppTheme.primaryColor,
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        supply.title,
                                        style: boldTextStyle,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Quantity : ",
                                        style: mainTextStyle,
                                      ),
                                      Text("${supply.quantity} Kg",
                                          style: mainTextStyle)
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Created at : ",
                                          style: mainTextStyle),
                                      Text(
                                          "${supply.createdAt.hour}:${supply.createdAt.minute}  ${supply.createdAt.day}/${supply.createdAt.month}/${supply.createdAt.year}",
                                          style: mainTextStyle)
                                    ],
                                  ),
                                  !addedList.contains(supply.id)
                                      ? Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                              gradient:
                                                  AppTheme().themeGradient,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: TextButton(
                                              onPressed: (() async {
                                                late var title;
                                                if (userType ==
                                                    insuranceAuthority) {
                                                  title = "Secure  Supply";
                                                } else if (userType ==
                                                    transportAuthority) {
                                                  title = "Select Package";
                                                } else {
                                                  title = "Select";
                                                }

                                                var res =
                                                    await AlertToSelectSupply(
                                                        context, supply,
                                                        titleText: title);

                                                if (res != null && res) {
                                                  if (userType ==
                                                      insuranceAuthority) {
                                                    //-------------- For Insurance Authority--------------
                                                    var addresp =
                                                        await supplyController
                                                            .setInsurance(
                                                                supply.id,
                                                                publicKey);
                                                    if (addresp != null) {
                                                      await DatabaseService
                                                              .removeField(
                                                                  "selectedUsers",
                                                                  insuranceAuthority,
                                                                  supply.id)
                                                          .then((res) async {
                                                        await showTransactionAlert(
                                                            context,
                                                            "Insurance Completed !",
                                                            addresp);
                                                        setState(() {
                                                          addedList.remove(
                                                              supply.id);
                                                        });
                                                      });

                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context)
                                                          .pop();
                                                    } else {
                                                      showRawAlert(context,
                                                          "Error ! try Again");
                                                    }
                                                  } else if (userType ==
                                                      transportAuthority) {
                                                    //-------------- For Transport Authority--------------
                                                    var addresp =
                                                        await supplyController
                                                            .setTransporter(
                                                                supply.id,
                                                                publicKey);
                                                    if (addresp != null) {
                                                      DatabaseService
                                                          .removeField(
                                                              "selectedUsers",
                                                              transportAuthority,
                                                              supply.id);
                                                      await showRawAlert(
                                                          context,
                                                          "Transport Package Selected !");
                                                      setState(() {
                                                        addedList
                                                            .remove(supply.id);
                                                      });
                                                      Navigator.of(context)
                                                          .pop();
                                                      Navigator.of(context)
                                                          .pop();
                                                    } else {
                                                      showRawAlert(context,
                                                          "Error ! try Again");
                                                    }
                                                  }
                                                }
                                              }),
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Colors.transparent)),
                                              child: Text(
                                                userType == insuranceAuthority
                                                    ? "Secure Supply"
                                                    : "Select Supply",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                        )
                                      : Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: Colors.green,
                                          size: 30,
                                        )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
          ),
        ],
      ),
    );
  }
}

class SupplyListCard extends StatefulWidget {
  final String? _title;
  final BuildContext _context;
  const SupplyListCard(
      {super.key, required BuildContext context, required String? title})
      : _title = title,
        _context = context;

  @override
  State<SupplyListCard> createState() => _SupplyListCardState();
}

class _SupplyListCardState extends State<SupplyListCard> {
  late String title;
  late BuildContext context;
  bool isFirstTime = true;
  late SupplyController supplyController;
  late List<Supply> buySupplyList = [];
  late List<String> addedBidsList = [];
  late TextStyle titleTextStyle;
  late TextStyle nameTextStyle;
  late TextStyle boldTextStyle;
  late TextStyle mainTextStyle;
  String fontName = 'roboto';

  @override
  void initState() {
    title = widget._title!;
    context = widget._context;
    initFontStyle();
    super.initState();
  }

  void initFontStyle() {
    titleTextStyle = TextStyle(
        fontFamily: fontName,
        color: Colors.grey.shade700,
        fontWeight: FontWeight.bold,
        fontSize: 18,
        decoration: TextDecoration.none);
    nameTextStyle = TextStyle(
        color: AppTheme.primaryColor,
        fontFamily: fontName,
        fontWeight: FontWeight.bold,
        fontSize: 17,
        decoration: TextDecoration.none);
    boldTextStyle = TextStyle(
        color: Colors.grey.shade800,
        fontFamily: fontName,
        fontSize: 15,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.none);
    mainTextStyle = TextStyle(
        fontFamily: fontName,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Colors.grey.shade700,
        decoration: TextDecoration.none);
  }

  void getSuppliesReadyToBuy() async {
    buySupplyList.clear();
    addedBidsList.clear();
    for (var supply in supplyController.allSupplies) {
      if (!supply.isBuyerAdded) {
        buySupplyList.add(supply);
        await isAlreadyBidded(supply.id);
      }
    }
    if (mounted) {
      setState(() {});
    }
  }

  isAlreadyBidded(String id) async {
    var res = await DatabaseService.isBidderPresent(id, publicKey);
    if (!res) {
      addedBidsList.add(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    supplyController = Provider.of<SupplyController>(context, listen: true);
    if (isFirstTime) {
      getSuppliesReadyToBuy();
      isFirstTime = false;
    }

    return Container(
      margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 0.1,
          bottom: MediaQuery.of(context).size.height * 0.08),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.grey.shade300),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Spacer(),
              Text(
                title,
                style: titleTextStyle,
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(90),
                      color: AppTheme.primaryColor),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: Divider(
              color: Colors.grey.shade700,
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 10),
            height: MediaQuery.of(context).size.height * 0.66,
            child: buySupplyList.isEmpty
                ? Center(
                    child: Text(
                      "No Ongoing Supplies found !!",
                      style: boldTextStyle,
                    ),
                  )
                : ListView.builder(
                    itemCount: buySupplyList.length,
                    itemBuilder: (context, index) {
                      Supply supply = buySupplyList[index];

                      return Container(
                        height: MediaQuery.of(context).size.height * .25,
                        margin: EdgeInsets.only(bottom: 20),
                        padding: EdgeInsets.only(right: 15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            Container(
                                //container for green border
                                width: 5,
                                height:
                                    MediaQuery.of(context).size.height * .25,
                                decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(90),
                                        bottomLeft: Radius.circular(90)))),
                            Container(
                              padding: EdgeInsets.only(left: 15, top: 10),
                              width: MediaQuery.of(context).size.width * 0.82,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "ID : ${supply.id}",
                                        style: nameTextStyle,
                                      ),
                                      Icon(
                                        Icons.info_outline_rounded,
                                        color: AppTheme.primaryColor,
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        supply.title,
                                        style: boldTextStyle,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Quantity : ",
                                        style: mainTextStyle,
                                      ),
                                      Text("${supply.quantity} Kg",
                                          style: mainTextStyle)
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Created at : ",
                                          style: mainTextStyle),
                                      Text(
                                          "${supply.createdAt.hour}:${supply.createdAt.minute}  ${supply.createdAt.day}/${supply.createdAt.month}/${supply.createdAt.year}",
                                          style: mainTextStyle)
                                    ],
                                  ),
                                  addedBidsList.contains(supply.id)
                                      ? Container(
                                          height: 40,
                                          decoration: BoxDecoration(
                                              gradient:
                                                  AppTheme().themeGradient,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: TextButton(
                                              onPressed: (() {
                                                AlertToAddBidAmount(
                                                    context, supply);
                                              }),
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all<
                                                              Color>(
                                                          Colors.transparent)),
                                              child: Text(
                                                "Make a Bid",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                        )
                                      : Icon(
                                          Icons.check_circle_outline_rounded,
                                          color: Colors.green,
                                          size: 30,
                                        )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
          ),
        ],
      ),
    );
  }
}

class UserListCard extends StatefulWidget {
  final List _users;
  final String? _title;
  final String supplyId;
  // static
  const UserListCard(
      {super.key,
      required List users,
      required String? title,
      required this.supplyId})
      : _users = users,
        _title = title;

  @override
  State<UserListCard> createState() => _UserListCard();
}

class _UserListCard extends State<UserListCard> {
  late List users;
  late String? title;
  bool selected = false;
  late List<Widget> userCards = [];
  // bool selected = false;
  late String currentSelected = '';
  late var response = null;
  @override
  void initState() {
    users = widget._users;
    title = widget._title;

    _fetchList();
    super.initState();
  }

  _fetchList() async {
    for (var user in users) {
      print(user.toString());
      userCards.add(GestureDetector(
        onTap: () async {
          setState(() {
            response = user;
            selected = true;
            currentSelected = user['name'];
          });

          if (user['type'] != insuranceAuthority) {
            setState(() {});
            return;
          }
          if (user.containsKey('policy')) {
            await AlertBoxes.selectPolicyAlertBox(
                context: context,
                policies: user['policy'],
                supplyId: widget.supplyId);
          } else {
            await AlertBoxes.selectPolicyAlertBox(
                context: context, policies: [], supplyId: widget.supplyId);
          }
          setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Container(
            padding: EdgeInsets.all(10),
            width: 250,
            decoration: BoxDecoration(
                gradient: AppTheme().themeGradient,
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  user['name'],
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  user['email'],
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),

                SizedBox(
                  height: 10,
                ),
                Divider(
                  thickness: 1,
                  height: 5,
                  color: AppTheme.secondaryColor,
                ),
                // ------------------- STARS ------------------------------
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: getStarListFromRatings(user['rating'], 25.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          padding: EdgeInsets.only(top: 10, bottom: 10, right: 10),
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Spacer(
                    flex: 2,
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      title != null
                          ? "SELECT ${title!.toUpperCase()}"
                          : "Select from list",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, null);
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 35,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                padding: EdgeInsets.only(top: 10),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: users.isEmpty
                        ? [Text("No ${title}s Avaialble !")]
                        : userCards,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    !selected && users.isNotEmpty
                        ? Text("Select ${title} From List !")
                        : SizedBox(),
                    selected
                        ? Container(
                            padding: EdgeInsets.only(left: 5, right: 5),
                            decoration: BoxDecoration(
                                gradient: AppTheme().themeGradient,
                                borderRadius: BorderRadius.circular(12)),
                            child: TextButton(
                              onPressed: () {
                                if (selected) {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(response);
                                }
                              },
                              style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all<Size>(
                                      Size(100, 20)),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.transparent)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "Select $currentSelected ",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Icon(Icons.check_circle_rounded,
                                      size: 30, color: Colors.white),
                                ],
                              ),
                            ),
                          )
                        : SizedBox(
                            width: 0,
                          ),
                  ],
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }
}

class BidderListCard extends StatefulWidget {
  final Map _bidders;
  final String? _title;
  const BidderListCard(
      {super.key, required Map bidders, required String? title})
      : _bidders = bidders,
        _title = title;

  @override
  State<BidderListCard> createState() => _BidderListCard();
}

class _BidderListCard extends State<BidderListCard> {
  late Map bidders;
  late String? title;
  late List<Widget> userCards = [];
  bool selected = false;
  late String currentSelected;
  late var response = null;
  late var dest = null;
  late var amount = null;
  @override
  void initState() {
    bidders = widget._bidders;
    title = widget._title;
    _fetchList();
    super.initState();
  }

  _fetchList() {
    bidders.forEach((id, bid) async {
      var bidderName =
          await DatabaseService().getNameByAddress(bid['bidderAddress']);
      var rating =
          await DatabaseService.getRating(address: bid['bidderAddress']);
      print("res : $rating");
      setState(() {
        userCards.add(GestureDetector(
          onTap: () async {
            setState(() {
              selected = true;
              response = bid['bidderAddress'];
              dest = bid['destination'];
              amount = bid['bidPrice'];
              currentSelected = bidderName!;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              padding: EdgeInsets.all(10),
              width: 250,
              decoration: BoxDecoration(
                  gradient: AppTheme().themeGradient,
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      "${bidderName}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Amount :",
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${bid['bidPrice']} ₹",
                        style: TextStyle(
                            color: AppTheme.secondaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Destination :",
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${bid['destination']}",
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Divider(
                    thickness: 1,
                    height: 5,
                    color: AppTheme.secondaryColor,
                  ),
                  // ------------------- STARS ------------------------------
                  Container(
                    padding: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: getStarListFromRatings(rating, 25.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Container(
          padding: EdgeInsets.only(top: 10, bottom: 10, right: 10),
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Spacer(
                    flex: 2,
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      title != null
                          ? "SELECT ${title!.toUpperCase()}"
                          : "Select from list",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700),
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, null);
                    },
                    child: Icon(
                      Icons.close_rounded,
                      size: 35,
                      color: Colors.grey,
                    ),
                  )
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                padding: EdgeInsets.only(top: 10),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: bidders.isEmpty
                        ? [Text("No ${title}s Avaialble !")]
                        : userCards,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    !selected && bidders.isNotEmpty
                        ? Text("Select ${title} From List !")
                        : SizedBox(),
                    selected
                        ? Container(
                            padding: EdgeInsets.only(left: 5, right: 5),
                            decoration: BoxDecoration(
                                gradient: AppTheme().themeGradient,
                                borderRadius: BorderRadius.circular(12)),
                            child: TextButton(
                              onPressed: () {
                                if (selected) {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop({
                                    "address": response,
                                    "destination": dest,
                                    "amount": amount
                                  });
                                }
                              },
                              style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all<Size>(
                                      Size(100, 20)),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.transparent)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    "Select $currentSelected ",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Icon(Icons.check_circle_rounded,
                                      size: 30, color: Colors.white),
                                ],
                              ),
                            ),
                          )
                        : SizedBox(
                            width: 0,
                          ),
                  ],
                ),
              )
            ],
          ),
        ),
      ]),
    );
  }
}
