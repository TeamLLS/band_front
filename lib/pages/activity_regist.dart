/*  
  clubId: Club Id, (Long) ㅇㅇ
  name, 활동 이름, (String) ㅇㅇ
  description: 활동 설명, (String) ㅇㅇ
  image: 활동 이미지, (MulitPartFile) ㅇㅇ
  location: 활동 장소, (String) 
  startTime: 활동 시작 시간, (Instant, ISO 8601)
  endTime: 활동 종료 시간, (Instnat, ISO 8601)
  deadline: 모집 종료 시간  (Instnat, ISO 8601)
*/

// TODO: 위치 선택 추가, 등록 성공 시 리로딩 추가

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:band_front/cores/api.dart';
import 'package:band_front/cores/repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

import '../cores/router.dart';
import '../cores/widget_utils.dart';

class ActivityRegistView extends StatefulWidget {
  const ActivityRegistView({super.key});

  @override
  State<ActivityRegistView> createState() => _ActivityRegistViewState();
}

class _ActivityRegistViewState extends State<ActivityRegistView> {
  XFile? _image;
  final TextEditingController nameCon = TextEditingController();
  final TextEditingController desCon = TextEditingController();
  DateTime? startTime;
  DateTime? endTime;
  DateTime? deadline;
  String? location;

  void _showSnackBar(String text) => showSnackBar(context, text);

  Future<DateTime?> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null) return null;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return null;

    return DateTime.utc(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _image = image);
    }
  }

  Future<void> registBtnListener() async {
    if (_image == null ||
        startTime == null ||
        endTime == null ||
        deadline == null ||
        location == null) {
      _showSnackBar("모두 입력해주세요");
      return;
    }

    bool ret = await context.read<ClubDetailRepo>().registActivity(nameCon.text,
        desCon.text, _image!, location!, startTime!, endTime!, deadline!);
    registBtnHandler(ret);
  }

  void registBtnHandler(bool ret) {
    if (ret == false) {
      _showSnackBar("등록 실패..");
      return;
    }
    _showSnackBar("등록 성공!");
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    String start = startTime == null ? "~" : formatToMDHM(startTime!);
    String end = endTime == null ? "~" : formatToMDHM(endTime!);
    String dead = deadline == null ? "~" : formatToMDHM(deadline!);
    location = context.watch<ClubDetailRepo>().buffer;

    return Scaffold(
      appBar: AppBar(title: const Text("모임 활동 등록하기")),
      body: SingleChildScrollView(
        child: Column(children: [
          const Text("모집을 위한 팸플릿 등이 있으신가요?"),
          InkWell(
            onTap: () async => await _pickImage(),
            child: _image == null
                ? Image.asset(
                    'assets/images/empty.png',
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 0.5,
                    fit: BoxFit.fitHeight,
                  )
                : Image.file(
                    File(_image!.path),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 0.5,
                    fit: BoxFit.fitHeight,
                  ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
            child: Text("어떤 목적의 활동인가요?"),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: inputTextUnit(nameCon),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
            child: Text("회원님들을 위해 자세한 설명을 부탁드려요"),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: desUnit(
              child: InputMultiTextUnit(desCon),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Text("모임을 가질 장소가 있으시다면"),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
            child: elevatedBtnUnit(
              onPressed: () => context.push(RouterPath.addressGet),
              borderColor: Colors.green[300]!,
              text: location == null ? "..." : location!,
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Text("약속 시간을 정해주세요"),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: elevatedBtnUnit(
              onPressed: () async {
                final pickedDateTime = await _pickDateTime();
                setState(() => startTime = pickedDateTime);
              },
              text: "$start  부터",
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: elevatedBtnUnit(
              onPressed: () async {
                final pickedDateTime = await _pickDateTime();
                setState(() => endTime = pickedDateTime);
              },
              text: "$end  까지",
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Text("인원은 언제까지 모집하실 건가요?"),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: elevatedBtnUnit(
              onPressed: () async {
                final pickedDateTime = await _pickDateTime();
                setState(() => deadline = pickedDateTime);
              },
              text: "$dead  까지",
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 48, 0, 0),
            child: Text("등록하기 전에 한번 더 확인해주세요"),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: elevatedBtnUnit(
              onPressed: () async => await registBtnListener(),
              borderColor: Colors.blue,
              text: "등록하기",
            ),
          ),
        ]),
      ),
    );
  }
}

class AddressGetView extends StatefulWidget {
  const AddressGetView({super.key});

  @override
  State<AddressGetView> createState() => _AddressGetViewState();
}

class _AddressGetViewState extends State<AddressGetView> {
  String apikey = "AIzaSyBycfPyrH12BjWPPgLzx_FxsOwH3YGb2EE";
  GoogleMapController? mapCon;
  TextEditingController addressCon = TextEditingController();
  LatLng? currentLocation;
  List<String> searchResultList = [];

  void checkBtnListener() async {
    if (addressCon.text == "") return;
    context.read<ClubDetailRepo>().setBuffer(addressCon.text);
    context.pop();
  }

  Future<void> searchBtnListener(String text) async {
    //구글 검색을 통해 검색 기록 저장
    await _searchToGoogle(text);
    // 검색 기록을 showBottomModalSheet로 출력
    _showLocationModal();
    // bottom sheet에서 선택된 주소로 이동
  }

  Future<void> _searchToGoogle(String queryValue) async {
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$queryValue&key=$apikey&language=ko');
    var response = await http.get(url);

    if (response.statusCode != 200) {
      _showSnackBar("검색 실패..");
      return;
    }

    var result = json.decode(response.body);
    List<dynamic> results = result['results'];

    searchResultList.clear();
    for (var place in results) {
      String address = place['formatted_address'];
      searchResultList.add(address);
    }
  }

  void _showLocationModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              padding: const EdgeInsets.only(top: 16),
              child: const Center(
                child: Text(
                  "위치 검색 결과",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searchResultList.length,
                itemBuilder: (context, index) {
                  String address = searchResultList[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 4),
                    child: ListTile(
                      title: Text(address),
                      onTap: () async {
                        // 주소를 선택했을 때 카메라 이동
                        addressCon.text = address;
                        Navigator.pop(context); // 모달 닫기
                        await _moveCamera(address);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _moveCamera(String address) async {
    if (address.isEmpty) return;

    // Google Geocoding API를 사용해 주소로 좌표 검색
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apikey');
    var response = await http.get(url);

    if (response.statusCode != 200) {
      _showSnackBar("위치 검색 실패..");
      return;
    }

    var result = json.decode(response.body);
    if (result['results'].isEmpty) {
      _showSnackBar("해당 주소의 위치를 찾을 수 없습니다.");
      return;
    }

    var location = result['results'][0]['geometry']['location'];
    double lat = location['lat'];
    double lng = location['lng'];

    currentLocation = LatLng(lat, lng);

    // 지도 카메라 이동
    if (currentLocation != null && mapCon != null) {
      mapCon!.animateCamera(
        CameraUpdate.newLatLng(currentLocation!),
      );
    }
  }

  Future<void> _setLocation() async {
    try {
      List<Location> locations = await locationFromAddress(addressCon.text);
      setState(() {
        currentLocation = LatLng(locations[0].latitude, locations[0].longitude);
      });
    } catch (e) {
      log('Error converting address to coordinates: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _initMapView();
  }

  Future<void> _initMapView() async {
    try {
      List<Location> locations = await locationFromAddress("경상북도 구미시 대학로 61");
      setState(() {
        currentLocation = LatLng(locations[0].latitude, locations[0].longitude);
      });
    } catch (e) {
      log('Error converting address to coordinates: $e');
    }
  }

  void _showSnackBar(String text) => showSnackBar(context, text);

  @override
  Widget build(BuildContext context) {
    double parentWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('장소 선택'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => checkBtnListener(),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.blue[300]),
              ),
              label: const Icon(Icons.check),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          currentLocation == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapCon = controller;
                  },
                  initialCameraPosition: CameraPosition(
                    target: currentLocation!,
                    zoom: 15.0,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('targetLocation'),
                      position: currentLocation!,
                    ),
                  },
                ),
          Container(
            padding: const EdgeInsets.all(8.0),
            width: parentWidth,
            child: Column(
              children: [
                desUnit(
                  child: searchUnit(
                    ctl: addressCon,
                    onSearchPressed: () async {
                      await searchBtnListener(addressCon.text);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
