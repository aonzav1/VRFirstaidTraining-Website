import 'package:flutter/material.dart';
import 'package:vrfirstaid/classes/scenarioData.dart';
import 'package:vrfirstaid/core/app_data.dart';
import 'package:vrfirstaid/core/app_style.dart';
import 'package:vrfirstaid/core/app_extension.dart';
import 'package:vrfirstaid/widgets/rating_bar.dart';

class ScenarioListView extends StatelessWidget {
  final bool isHorizontal;
  final Function(ScenarioData scenario)? onTap;
  final List<ScenarioData> scenarioList;

  const ScenarioListView({
    Key? key,
    this.isHorizontal = true,
    this.onTap,
    required this.scenarioList,
  }) : super(key: key);

  Widget _scenarioScore(ScenarioData scenario) {
    return Row(
      children: [
        StarRatingBar(score: scenario.difficulty.toDouble()),
        const SizedBox(width: 10),
        Text(scenario.difficulty.toString(), style: h4Style),
      ],
    ).fadeAnimation(1.0);
  }

  Widget _scenarioImage(String image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Image.asset(image, width: 150, height: 150),
    ).fadeAnimation(0.4);
  }

    Widget _networkScenarioImage(String image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.0),
      child: Image.network(AppData.imageURL+image, width: 150, height: 150),
    ).fadeAnimation(0.4);
  }

  Widget _listViewItem(ScenarioData scenario, int index) {
    var locationIndex = AppData.availableMaps.keys.toList()[scenario.location];
    var placeHolderImage = AppData.availableMaps[locationIndex]![1];

    Widget widget;
    widget = isHorizontal == true
        ? Column(
            children: [
              Hero(tag: index, child: scenario.thumbnail == "" ? _scenarioImage(placeHolderImage) : _networkScenarioImage(scenario.thumbnail),),
              const SizedBox(height: 10),
              Text(scenario.name.addOverFlow, style: h4Style)
                  .fadeAnimation(0.8),
              _scenarioScore(scenario),
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              scenario.thumbnail == "" ? _scenarioImage(placeHolderImage) : _networkScenarioImage(scenario.thumbnail),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(scenario.name, style: h4Style).fadeAnimation(0.8),
                      const SizedBox(height: 5),
                      _scenarioScore(scenario),
                      const SizedBox(height: 5),
                      Text(
                        scenario.description,
                        style: h5Style.copyWith(fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ).fadeAnimation(1.4)
                    ],
                  ),
                ),
              )
            ],
          );

    return GestureDetector(
      onTap: () => onTap?.call(scenario),
      child: widget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return isHorizontal == true
        ? SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: scenarioList.length,
              itemBuilder: (_, index) {
                ScenarioData scenario = scenarioList[index];
                return _listViewItem(scenario, index);
              },
              separatorBuilder: (BuildContext context, int index) {
                return const Padding(padding: EdgeInsets.only(left: 15));
              },
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            reverse: true,
            physics: const ClampingScrollPhysics(),
            itemCount: scenarioList.length,
            itemBuilder: (_, index) {
              ScenarioData scenario = scenarioList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 15, top: 10),
                child: _listViewItem(scenario, index),
              );
            },
          );
  }
}
