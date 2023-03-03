import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:supplychain/services/functions.dart';
import 'package:supplychain/utils/supply.dart';
import 'package:supplychain/utils/constants.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class NoteController extends ChangeNotifier {
  List<Supply> notes = [];
  List<Supply> userSupply = [];
  bool isLoading = true;
  late int noteCount;
  final String _rpcUrl = goreli_url;
  final String _wsUrl = ws_url;

  late Web3Client _client;
  late String _abiStringFile;

  late Credentials _credentials;
  late EthereumAddress _contractAddress;
  late DeployedContract _contract;
  // getestimated gas price
  late EtherAmount _gasPrice;

  late ContractFunction _addSupply;
  late ContractFunction _getSupply;
  late ContractFunction _getSupplies;
  late ContractFunction _getUserSupplies;
  late ContractFunction _totalSupplies;
  late ContractFunction _addBuyer;
  late ContractFunction _addTransporter;
  late ContractFunction _addInsurance;

  late ContractEvent _noteAddedEvent;
  late ContractEvent _noteDeletedEvent;

  NoteController() {
    init();
  }

  init() async {
    _client = Web3Client(_rpcUrl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsUrl).cast<String>();
    });
    await getAbi();
    await getCreadentials();
    await getDeployedContract();
    _updateGasPrice();

    // var _basePrice   = await _client.get
  }

  void _updateGasPrice() async {
    _gasPrice = await _client
        .getBlockInformation()
        .then((value) => value.baseFeePerGas!);
  }

  Future<void> getAbi() async {
    _abiStringFile = await rootBundle.loadString("assets/abi.json");
  }

  Future<void> getCreadentials() async {
    _credentials = EthPrivateKey.fromHex(privateKey);
  }

  Future<void> getDeployedContract() async {
    _contractAddress = EthereumAddress.fromHex(deployedContractAddress);
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiStringFile, "Storage"), _contractAddress);
    _addSupply = _contract.function("addSupply");

    _getSupply = _contract.function("getSupply");
    _getSupplies = _contract.function("getSupplies");
    _getUserSupplies = _contract.function("getSuppliesOfUser");
    _totalSupplies = _contract.function("totalSupplies");
    _addBuyer = _contract.function("addBuyer");
    _addTransporter = _contract.function("addTransporter");
    _addInsurance = _contract.function("addInsurance");

    // _noteAddedEvent = _contract.event("NoteAdded");
    // _noteDeletedEvent = _contract.event("NoteDeleted");
    await getNotes();
    await getSuppliesOfUser();
  }

  getNotes() async {
    isLoading = true;
    try {
      List response = await _client
          .call(contract: _contract, function: _getSupplies, params: []);
      if (response.length == 0) {
        return;
      }
      List<dynamic> notesList = response[0];

      // print(notesList.toString());
      noteCount = notesList.length;
      notes.clear();
      for (List<dynamic> note in notesList) {
        Supply n = Supply(
          id: note[0].toString(),
          title: note[1],
          quantity: note[2].toString(),
          temperature: note[3].toString(),
          supplierAddress: note[4],
          createdAt: DateTime.parse(note[5]),
          initiated: note[6],
          isBuyerAdded: note[7],
          isTransporterAdded: note[8],
          isInsuranceAdded: note[9],
          isCompleted: note[10],
        );
        notes.add(n);
        print(note.toString());
      }
    } catch (e) {
      print(e);
    }
    isLoading = false;
    notifyListeners();
    return notes;
  }

  getSupplyByID(BigInt id) async {
    isLoading = true;
    try {
      List response = await _client
          .call(contract: _contract, function: _getSupply, params: [id]);
      if (response.length == 0) {
        return;
      }
      List<dynamic> supply = response[0];
      Supply n = Supply(
        id: supply[0].toString(),
        title: supply[1],
        quantity: supply[2].toString(),
        temperature: supply[3].toString(),
        supplierAddress: supply[4],
        createdAt: DateTime.parse(supply[5]),
        initiated: supply[6],
        isBuyerAdded: supply[7],
        isTransporterAdded: supply[8],
        isInsuranceAdded: supply[9],
        isCompleted: supply[10],
      );
      userSupply.add(n);
    } catch (e) {
      print(e);
    }
    isLoading = false;
    notifyListeners();
  }

  getSuppliesOfUser() async {
    isLoading = true;
    try {
      List response = await _client.call(
          contract: _contract,
          function: _getUserSupplies,
          params: [EthereumAddress.fromHex(publicKey)]);

      if (response.length == 0) {
        return;
      }
      var userSupplyIDList = response[0];
      // print("ID list : " + userSupplyIDList.toString());

      userSupply.clear();
      for (var supplyID in userSupplyIDList) {
        await getSupplyByID(supplyID);
      }
    } catch (e) {
      print(e);
    }
    isLoading = false;
    notifyListeners();
    // return notes;
  }

  addSupply(String name, double quantity, double temp) async {
    String currentStamp = DateTime.now().toString();
    await getCreadentials();
    _updateGasPrice();
    publicKey = _credentials.address.toString();
    List<dynamic> args = [
      name,
      BigInt.from(quantity),
      BigInt.from(temp),
      EthereumAddress.fromHex(publicKey),
      currentStamp
    ];
    try {
      isLoading = true;
      notifyListeners();
      String response = await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          gasPrice: _gasPrice,
          contract: _contract,
          function: _addSupply,
          parameters: args,
        ),
        chainId: 5,
      );

      await getNotes();
      await getSuppliesOfUser();

      isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      print("Error : ${e.toString()}");
      isLoading = false;
      notifyListeners();
    }
  }

  setBuyer(String id, String buyerAddress) async {
    isLoading = true;
    notifyListeners();
    List<dynamic> args = [
      BigInt.from(int.parse(id)),
      EthereumAddress.fromHex(buyerAddress)
    ];

    try {
      String response = await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          gasPrice: _gasPrice,
          contract: _contract,
          function: _addBuyer,
          parameters: args,
        ),
        chainId: 5,
      );

      await getNotes();
      await getSuppliesOfUser();

      isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      print("Error while selecting Buyer : ${e.toString()}");
      isLoading = false;
      notifyListeners();
    }
  }

  setTransporter(String id, String transporterAddress) async {
    isLoading = true;
    notifyListeners();
    List<dynamic> args = [
      BigInt.from(int.parse(id)),
      EthereumAddress.fromHex(transporterAddress)
    ];

    try {
      String response = await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          gasPrice: _gasPrice,
          contract: _contract,
          function: _addTransporter,
          parameters: args,
        ),
        chainId: 5,
      );

      await getNotes();
      await getSuppliesOfUser();

      isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      print("Error while selecting Transporter : ${e.toString()}");
      isLoading = false;
      notifyListeners();
    }
  }

  setInsurance(String id, String insuranceAddress) async {
    isLoading = true;
    notifyListeners();
    List<dynamic> args = [
      BigInt.from(int.parse(id)),
      EthereumAddress.fromHex(insuranceAddress)
    ];

    try {
      String response = await _client.sendTransaction(
        _credentials,
        Transaction.callContract(
          gasPrice: _gasPrice,
          contract: _contract,
          function: _addInsurance,
          parameters: args,
          // maxFeePerGas: EtherAmount.inWei(_gasPrice.getInWei * BigInt.from(2)),
        ),
        chainId: 5,
      );

      await getNotes();
      await getSuppliesOfUser();

      isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      print("Error while selecting Transporter : ${e.toString()}");
      isLoading = false;
      notifyListeners();
    }
  }
}

// 08:18:02:03:2023