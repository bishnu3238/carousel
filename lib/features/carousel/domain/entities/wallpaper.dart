import 'package:equatable/equatable.dart';

class Wallpaper extends Equatable{
  final String path;
  final bool isNetwork;
  final int? id;


  const Wallpaper({required this.path, this.isNetwork = false, this.id});

  @override
  List<Object?> get props => [path, isNetwork, id];

}