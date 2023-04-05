import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/material.dart';
import 'package:vrfirstaid/classes/patient.dart';
import 'package:vrfirstaid/classes/scenarioData.dart';
import 'package:vrfirstaid/core/app_data.dart';
import 'package:vrfirstaid/main.dart';
import 'package:vrfirstaid/services/apiprovider.dart';
import 'package:vrfirstaid/widgets/colorbutton.dart';
import 'package:vrfirstaid/widgets/successAlert.dart';
import 'package:vrfirstaid/widgets/textItem.dart';

class CreatePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CreatePageState();
  }
}

class _CreatePageState extends State<CreatePage> {
  var apiProvider = ApiProvider();

  //General
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descController = TextEditingController();
  TextEditingController _introController = TextEditingController();

  File _file = File("zz");
  Uint8List webImage = Uint8List(10);
  String imageURL = "";

  String choosenDifficulty = AppData.difficultyLevel.first;
  String choosenMapPath = AppData.availableMaps.keys.first;
  final ImagePicker _picker = ImagePicker();

  //NPC Editor
  List<Patient> scenePatients = [];

  TextEditingController _npcController = TextEditingController();
  String choosenAge = AppData.age.first;
  String choosenInjury = AppData.injuries.first;
  int choosenAppearance = 0;
  int choosenPainSensitivity = 1;
  int choosenEmotionalSensitivity = 1;
  int choosenBodyResistance = 1;
  int choosenInitialBodyHealth = 2;
  int choosenInitialMentalHealth = 2;
  int choosenPlacement = 0;
  double patientScoreMult = 1.0;
  double injuryTime = 0;

  int editingPatient = 0;

  //Item placement
  bool allowTablet = false;
  bool showGuide = false;
  bool showStatus = false;

  var itemCount = List.filled(AppData.itemList.length, -1, growable: false);

  //Goals and condition
  double timeLimit = 180;
  double timeScoreMult = 1.0;
  double interactMult = 1.0;
  bool endOnDeath = true;
  bool endOnWrong = false;
  double penaltyScoreMult = 1.0;
  double bonusScoreMult = 1.0;
  double passScore = 1000;
  double goldBadgeScore = 1500;

  checkAuth() async {
    var token = await tokenService.getMyToken();
    if (token != null) {
      var result = await apiProvider.checkToken();
      if (result.statusCode == 200) {
        isLoggedIn = true;
      } else {
        isLoggedIn = false;
      }
    } else {
      isLoggedIn = false;
    }
    if (!isLoggedIn) Navigator.popAndPushNamed(context, "/login");
  }

  Future<PermissionStatus> requestPermissions() async {
    if (kIsWeb) return PermissionStatus.granted;
    await Permission.photos.request();
    return Permission.photos.status;
  }

  int _currentStep = 0;
  StepperType stepperType = StepperType.vertical;

  tapped(int step) {
    setState(() => _currentStep = step);
  }

  continued() {
    _currentStep < 5 ? setState(() => _currentStep += 1) : scenarioCreate();
  }

  scenarioCreate() async {
    var thumbnailLink = "";
    try {
      final response = await apiProvider.uploadWebImage(webImage);
      thumbnailLink = jsonDecode(response.body)["filename"];
    } catch (err) {
      print(err);
    }

    ScenarioData newScenarioData = ScenarioData(
        "User",
        _nameController.text,
        _descController.text,
        AppData.difficultyLevel.indexOf(choosenDifficulty),
        _introController.text,
        AppData.availableMaps.keys.toList().indexOf(choosenMapPath),
        thumbnailLink,
        scenePatients,
        itemCount,
        timeLimit.toInt(),
        timeScoreMult,
        interactMult,
        endOnDeath,
        endOnWrong,
        penaltyScoreMult,
        bonusScoreMult,
        allowTablet,
        showGuide,
        showStatus,
        passScore.toInt(),
        goldBadgeScore.toInt(),
        DateTime.now(),
        DateTime.now());
    var data = newScenarioData.toJson();
    try {
      final response = await apiProvider.addScenario(data);
      print(response.body);
      ShowSuccessDialog("Create scenario successfully", context);
    } catch (err) {
      print(err);
    }
  }

  cancel() {
    _currentStep > 0 ? setState(() => _currentStep -= 1) : null;
  }

  savePatient() {
    if (scenePatients.length == 3) {
      //Show error
      return;
    }
    if (_npcController.text == "") {
      //Show error
      return;
    }

    Patient newPatient = Patient(
        _npcController.text,
        choosenAge,
        choosenAppearance,
        choosenInjury,
        injuryTime,
        choosenPainSensitivity,
        choosenBodyResistance,
        choosenEmotionalSensitivity,
        choosenInitialBodyHealth,
        choosenInitialMentalHealth,
        patientScoreMult,
        choosenPlacement);

    if (editingPatient < scenePatients.length) {
      scenePatients[editingPatient] = newPatient;
      ShowSuccessDialog("${newPatient.name} information is updated", context);
    } else {
      scenePatients.add(newPatient);
      ShowSuccessDialog("${newPatient.name} is sucussfully added", context);
    }
    setState(() {
      if (editingPatient <= 2) {
        editingPatient += 1;
      }
      loadData(editingPatient);
    });
  }

  deletePatient() {
    scenePatients.removeAt(editingPatient);

    setState(() {
      editingPatient = 0;
      loadData(editingPatient);
    });
  }

  loadData(int index) {
    if (index < scenePatients.length) {
      var p = scenePatients[index];
      _npcController.text = p.name;
      choosenAge = p.age;
      choosenInjury = p.injury;
      choosenAppearance = p.appearance;
      choosenPainSensitivity = p.painSensitivity;
      choosenEmotionalSensitivity = p.emotionalSensitivity;
      choosenBodyResistance = p.bodyResistance;
      choosenInitialBodyHealth = p.initialBodyHealth;
      choosenInitialMentalHealth = p.initialMentalHealth;
      choosenPlacement = p.placement;
      injuryTime = p.injuryTime;
    } else {
      _npcController.text = "";
      choosenAge = "Adult";
      choosenInjury = AppData.injuries.first;
      choosenAppearance = 0;
      choosenPainSensitivity = 1;
      choosenEmotionalSensitivity = 1;
      choosenBodyResistance = 1;
      choosenInitialBodyHealth = 2;
      choosenInitialMentalHealth = 2;
      choosenPlacement = 0;
      injuryTime = 0;
    }
  }

  uploadImage() async {
    var permissionStatus = requestPermissions();

    // MOBILE
    if (!kIsWeb && await permissionStatus.isGranted) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxHeight: 256,
          maxWidth: 256,
          imageQuality: 70);

      if (image != null) {
        var selected = File(image.path);

        setState(() {
          _file = selected;
        });
      } else {
        print("No file selected");
      }
    }
    // WEB
    else if (kIsWeb) {
      final ImagePicker _picker = ImagePicker();
      XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxHeight: 256,
          maxWidth: 256,
          imageQuality: 70);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          _file = File("a");
          webImage = f;
        });
      } else {
        print("No file selected");
      }
    } else {
      print("Permission not granted");
    }
  }

  @override
  void initState() {
    super.initState();
    checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    var describeStep = Step(
      title: const Text('Describe your scenario'),
      content: Column(
        children: <Widget>[
          const SizedBox(
            height: 12,
          ),
          TextItem("Scenario name", _nameController, false, () {}),
          const SizedBox(
            height: 12,
          ),
          TextItem("Description", _descController, false, () {}),
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              const Text("Difficulty: "),
              const SizedBox(
                width: 12,
              ),
              DropDown(AppData.difficultyLevel, choosenDifficulty, (value) {
                setState(() {
                  choosenDifficulty = value!;
                });
              })
            ],
          ),
          const SizedBox(
            height: 12,
          ),
        ],
      ),
      isActive: _currentStep >= 0,
      state: _currentStep >= 0 ? StepState.complete : StepState.disabled,
    );

    var placeStep = Step(
      title: Text('Choose place'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              const Text("Location: "),
              const SizedBox(
                width: 12,
              ),
              DropDown(AppData.availableMaps.keys.toList(), choosenMapPath,
                  (value) {
                setState(() {
                  choosenMapPath = value!;
                });
              })
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              ClipRRect(
                child: Image.asset(AppData.availableMaps[choosenMapPath]![0],
                    width: 512, height: 512),
              ),
              const SizedBox(
                width: 12,
              ),
              ClipRRect(
                child: Image.asset(AppData.availableMaps[choosenMapPath]![1],
                    width: 512, height: 512),
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
        ],
      ),
      isActive: _currentStep >= 1,
      state: _currentStep >= 1 ? StepState.complete : StepState.disabled,
    );

    var patientStep = Step(
      title: Text('Place patients'),
      content: Column(
        children: <Widget>[
          const SizedBox(
            height: 12,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(children: [
                ClipRRect(
                  child: Image.asset(AppData.availableMaps[choosenMapPath]![0],
                      width: 512, height: 512),
                ),
                const SizedBox(
                  height: 12,
                ),
                const Text('List of patients in the scene'),
                const SizedBox(
                  height: 12,
                ),
                ChooseImageChoice(
                    scenePatients.map((patient) {
                      switch (patient.age) {
                        case "Kid":
                          return AppData.kidImagePaths[patient.appearance];
                        case "Adult":
                          return AppData.adultImagePaths[patient.appearance];
                        case "Old":
                          return AppData.oldImagePaths[patient.appearance];
                      }
                      return "";
                    }).toList(),
                    editingPatient, (value) {
                  setState(() {
                    editingPatient = value;
                    loadData(value);
                  });
                }, true),
                const SizedBox(
                  height: 12,
                ),
              ]),
              const SizedBox(
                width: 24,
              ),
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 3,
                        blurRadius: 5,
                        offset: Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(24),
                  width: 512,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(editingPatient < scenePatients.length
                          ? 'Edit patient'
                          : 'Create new patient'),
                      const SizedBox(
                        height: 12,
                      ),
                      Container(
                          child:
                              TextItem("Name", _npcController, false, () {})),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          const Text('Age: '),
                          const SizedBox(
                            width: 12,
                          ),
                          DropDown(AppData.age, choosenAge, (value) {
                            setState(() {
                              choosenAge = value!;
                            });
                          })
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text('Appearance'),
                      const SizedBox(
                        height: 12,
                      ),
                      ChooseImageChoice(
                          choosenAge == "Adult"
                              ? AppData.adultImagePaths
                              : (choosenAge == "Kid"
                                  ? AppData.kidImagePaths
                                  : AppData.oldImagePaths),
                          choosenAppearance, (value) {
                        setState(() {
                          choosenAppearance = value;
                        });
                      }),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          const Text('Injury: '),
                          const SizedBox(
                            width: 12,
                          ),
                          DropDown(AppData.injuries, choosenInjury, (value) {
                            setState(() {
                              choosenInjury = value!;
                            });
                          })
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          const Text('Pain sensitivity: '),
                          const SizedBox(
                            width: 12,
                          ),
                          ChooseChoice(AppData.level, choosenPainSensitivity,
                              (index) {
                            setState(() {
                              choosenPainSensitivity = index;
                            });
                          })
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          const Text('Emotional sensitivity: '),
                          const SizedBox(
                            width: 12,
                          ),
                          ChooseChoice(
                              AppData.level, choosenEmotionalSensitivity,
                              (index) {
                            setState(() {
                              choosenEmotionalSensitivity = index;
                            });
                          })
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          const Text('Body resistance: '),
                          const SizedBox(
                            width: 12,
                          ),
                          ChooseChoice(AppData.level, choosenBodyResistance,
                              (index) {
                            setState(() {
                              choosenBodyResistance = index;
                            });
                          })
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          const Text('Body health: '),
                          const SizedBox(
                            width: 12,
                          ),
                          ChooseChoice(
                              AppData.healthState, choosenInitialBodyHealth,
                              (index) {
                            setState(() {
                              choosenInitialBodyHealth = index;
                            });
                          })
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          const Text('Mental health: '),
                          const SizedBox(
                            width: 12,
                          ),
                          ChooseChoice(
                              AppData.healthState, choosenInitialMentalHealth,
                              (index) {
                            setState(() {
                              choosenInitialMentalHealth = index;
                            });
                          })
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          const Text('Score mutliplier: '),
                          const SizedBox(
                            width: 12,
                          ),
                          Slider(
                              divisions: 8,
                              max: 2,
                              value: patientScoreMult,
                              onChanged: ((value) => setState(() {
                                    patientScoreMult = value;
                                  }))),
                          Text(patientScoreMult.toStringAsFixed(2)),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Row(children: [
                          const Text('Location: '),
                          const SizedBox(
                            width: 12,
                          ),
                          ChooseChoice(AppData.location, choosenPlacement,
                              (index) {
                            setState(() {
                              choosenPlacement = index;
                            });
                          })
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(children: [
                        SizedBox(
                          width: 120,
                          height: 48,
                          child: ColorButton(
                              editingPatient < scenePatients.length
                                  ? "Save"
                                  : "Add",
                              Theme.of(context).primaryColor,
                              savePatient,
                              Colors.white),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        editingPatient < scenePatients.length
                            ? SizedBox(
                                width: 120,
                                height: 48,
                                child: ColorButton(
                                    "Delete",
                                    Theme.of(context).primaryColor,
                                    deletePatient,
                                    Colors.white),
                              )
                            : Container(),
                      ]),
                    ],
                  )),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
        ],
      ),
      isActive: _currentStep >= 2,
      state: _currentStep >= 2 ? StepState.complete : StepState.disabled,
    );

    var itemsStep = Step(
      title: Text('Place items and helpers'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CheckBoxItem(
              allowTablet, "Allow player to use Tablet (see first aid steps)",
              (value) {
            setState(() {
              allowTablet = value!;
            });
          }),
          const SizedBox(
            height: 12,
          ),
          CheckBoxItem(
              showGuide, "Display graphics that helps and guides player",
              (value) {
            setState(() {
              showGuide = value!;
            });
          }),
          const SizedBox(
            height: 12,
          ),
          CheckBoxItem(showStatus, "Display status of patients", (value) {
            setState(() {
              showStatus = value!;
            });
          }),
          const SizedBox(
            height: 12,
          ),
          Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 2), // changes position of shadow
                  ),
                ],
              ),
              padding: EdgeInsets.all(24),
              width: MediaQuery.of(context).size.width * 0.25,
              child: Column(
                children: [
                  const Text(
                    "Item usage limit (-1 for unlimited)",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Wrap(
                    spacing: 5.0,
                    children: List<Widget>.generate(
                      AppData.itemList.length,
                      (int index) {
                        return Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppData.itemList[index]),
                              DropDown(
                                  AppData.counter.map((c) {
                                    return c.toString();
                                  }).toList(),
                                  itemCount[index].toString(), (value) {
                                setState(() {
                                  itemCount[index] = int.parse(value!);
                                });
                              })
                            ],
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ],
              )),
          const SizedBox(
            height: 24,
          ),
        ],
      ),
      isActive: _currentStep >= 3,
      state: _currentStep >= 3 ? StepState.complete : StepState.disabled,
    );

    var goalsStep = Step(
      title: Text('Goals and conditions'),
      content: Column(
        children: <Widget>[
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              const Text('Time limit: '),
              const SizedBox(
                width: 12,
              ),
              Slider(
                  divisions: 19,
                  min: 30,
                  max: 600,
                  value: timeLimit,
                  onChanged: ((value) => setState(() {
                        timeLimit = value;
                      }))),
              Text(timeLimit.toStringAsFixed(0)),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              const Text('Time score multiplier: '),
              const SizedBox(width: 12),
              Slider(
                  divisions: 8,
                  max: 2,
                  value: timeScoreMult,
                  onChanged: ((value) => setState(() {
                        timeScoreMult = value;
                      }))),
              Text(timeScoreMult.toStringAsFixed(2)),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          /*  Row(
            children: [
              const Text('Interaction time multiplier: '),
              const SizedBox(width: 12),
              Slider(
                  divisions: 8,
                  max: 2,
                  value: interactMult,
                  onChanged: ((value) => setState(() {
                        interactMult = value;
                      }))),
              Text(interactMult.toStringAsFixed(2)),
            ],
          ),*/
          const SizedBox(
            height: 12,
          ),
          CheckBoxItem(endOnDeath, "Do end if any of patient died", (value) {
            setState(() {
              endOnDeath = value!;
            });
          }),
          const SizedBox(
            height: 12,
          ),
          /*  CheckBoxItem(endOnWrong, "Do end if any of do wrong on any step",
              (value) {
            setState(() {
              endOnWrong = value!;
            });
          }),
          const SizedBox(
            height: 12,
          ),*/
          Row(
            children: [
              const Text('Penalty score multiplier: '),
              const SizedBox(width: 12),
              Slider(
                  divisions: 8,
                  max: 2,
                  value: penaltyScoreMult,
                  onChanged: ((value) => setState(() {
                        penaltyScoreMult = value;
                      }))),
              Text(penaltyScoreMult.toStringAsFixed(2)),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              const Text('Bonus score multiplier: '),
              const SizedBox(width: 12),
              Slider(
                  divisions: 8,
                  max: 2,
                  value: bonusScoreMult,
                  onChanged: ((value) => setState(() {
                        bonusScoreMult = value;
                      }))),
              Text(bonusScoreMult.toStringAsFixed(2)),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              const Text('Passing score: '),
              const SizedBox(width: 12),
              Slider(
                  divisions: 19,
                  min: 100,
                  max: 2000,
                  value: passScore,
                  onChanged: ((value) => setState(() {
                        passScore = value;
                      }))),
              Text(passScore.toStringAsFixed(0)),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              const Text('Gold badge score: '),
              const SizedBox(width: 12),
              Slider(
                  divisions: 19,
                  min: 200,
                  max: 4000,
                  value: goldBadgeScore,
                  onChanged: ((value) => setState(() {
                        goldBadgeScore = value;
                      }))),
              Text(goldBadgeScore.toStringAsFixed(0)),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
        ],
      ),
      isActive: _currentStep >= 4,
      state: _currentStep >= 4 ? StepState.complete : StepState.disabled,
    );

    var moreStep = Step(
      title: const Text('Tell something to your player'),
      content: Column(
        children: <Widget>[
          const SizedBox(
            height: 12,
          ),
          TextItem("What you want to tell", _introController, false, () {}),
          const SizedBox(
            height: 12,
          ),
          Row(
            children: const [
              Text("Thumbnail image: "),
              SizedBox(
                width: 12,
              )
            ],
          ),
          const SizedBox(
            height: 12,
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  uploadImage();
                },
                child: Container(
                  color: Colors.grey,
                  width: 256,
                  height: 256,
                  //  radius: 55,
                  // backgroundColor: Colors.grey,
                  child: (_file.path != "zz")
                      ? ClipRRect(
                          child: (kIsWeb)
                              ? Image.memory(webImage,
                                  width: 100, height: 100, fit: BoxFit.cover)
                              : Image.file(_file,
                                  width: 100, height: 100, fit: BoxFit.cover),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                          ),
                          width: 100,
                          height: 100,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.grey[800],
                          ),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ),
        ],
      ),
      isActive: _currentStep >= 5,
      state: _currentStep >= 5 ? StepState.complete : StepState.disabled,
    );

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 160),
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            const SizedBox(
              height: 12,
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                "Create new scenario",
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            Expanded(
              child: Stepper(
                type: stepperType,
                physics: const ScrollPhysics(),
                currentStep: _currentStep,
                onStepTapped: (step) => tapped(step),
                onStepContinue: continued,
                onStepCancel: cancel,
                controlsBuilder: (context, _) {
                  return Row(
                    children: <Widget>[
                      Container(
                        width: 120,
                        height: 48,
                        child: ColorButton(
                            _currentStep == 5 ? "Confirm" : "Next",
                            Theme.of(context).primaryColor,
                            continued,
                            Colors.white),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      _currentStep == 0
                          ? Container()
                          : Container(
                              height: 48,
                              width: 120,
                              child: ColorButton("Prev", Colors.grey.shade300,
                                  cancel, Theme.of(context).primaryColor),
                            ),
                    ],
                  );
                },
                steps: <Step>[
                  describeStep,
                  placeStep,
                  patientStep,
                  itemsStep,
                  goalsStep,
                  moreStep,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget DropDown(
      List<String> items, String choosen, ValueChanged<String?> onChanged) {
    return DropdownButton<String>(
      value: choosen,
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 12,
      style: const TextStyle(color: Colors.black87),
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget ChooseChoice(
      List<String> items, int value, Function(int) onIndexSelected) {
    return Wrap(
      spacing: 5.0,
      children: List<Widget>.generate(
        items.length,
        (int index) {
          return ChoiceChip(
            label: Text(items[index]),
            selectedColor: Theme.of(context).primaryColor,
            selected: value == index,
            labelStyle: TextStyle(
              color: value != index ? Colors.black : Colors.white,
            ),
            onSelected: (bool selected) {
              if (selected) {
                onIndexSelected(index);
              }
            },
          );
        },
      ).toList(),
    );
  }

  Widget ChooseImageChoice(
      List<String> items, int value, Function(int) onIndexSelected,
      [bool? allowAdd]) {
    allowAdd ??= false;

    return Wrap(
      spacing: 5.0,
      children: List<Widget>.generate(
        allowAdd ? items.length + 1 : items.length,
        (int index) {
          return GestureDetector(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: index == value
                    ? Colors.grey.shade300
                    : Colors.grey.shade500,
              ),
              child: index >= items.length
                  ? const Icon(Icons.add, size: 32)
                  : Image.asset(items[index],
                      colorBlendMode: BlendMode.multiply,
                      color: index == value
                          ? Colors.transparent
                          : Colors.black.withOpacity(0.5)),
            ),
            onTap: () {
              onIndexSelected(index);
            },
          );
        },
      ).toList(),
    );
  }

  Widget CheckBoxItem(bool value, String label, Function(bool?) onChanged) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Theme.of(context).primaryColor;
      }
      return Colors.grey.shade600;
    }

    return Row(
      children: [
        Checkbox(
            checkColor: Colors.white,
            fillColor: MaterialStateProperty.resolveWith(getColor),
            value: value,
            onChanged: onChanged),
        const SizedBox(
          width: 12,
        ),
        Text(label)
      ],
    );
  }
}
