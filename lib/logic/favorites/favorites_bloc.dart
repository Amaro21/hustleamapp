import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product_models.dart';
import '../../data/dataresources/local_db.dart';

// EVENTS
abstract class FavoritesEvent {}

class LoadFavorites extends FavoritesEvent {}

class ToggleFavorite extends FavoritesEvent {
  final Product product;
  ToggleFavorite(this.product);
}

// STATE
class FavoritesState {
  final List<Product> items;
  FavoritesState({this.items = const []});
}

// BLOC
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc() : super(FavoritesState()) {
    on<LoadFavorites>((event, emit) async {
      final items = await LocalDatabase.instance.getFavorites();
      emit(FavoritesState(items: items));
    });

    on<ToggleFavorite>((event, emit) async {
      final isFav = await LocalDatabase.instance.isFavorite(event.product.id);

      if (isFav) {
        await LocalDatabase.instance.removeFavorite(event.product.id);
      } else {
        await LocalDatabase.instance.addFavorite(event.product);
      }
      add(LoadFavorites());
    });
  }
}
