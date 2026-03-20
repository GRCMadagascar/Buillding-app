import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/shop.dart';
import '../../domain/usecases/shop_usecases.dart';
import '../../../../core/usecase/usecase.dart';

part 'shop_event.dart';
part 'shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final GetShopUseCase getShopUseCase;
  final UpdateShopUseCase updateShopUseCase;

  ShopBloc({
    required this.getShopUseCase,
    required this.updateShopUseCase,
  }) : super(ShopInitial()) {
    on<LoadShopEvent>(_onLoadShop);
    on<UpdateShopEvent>(_onUpdateShop);
  }

  Future<void> _onLoadShop(LoadShopEvent event, Emitter<ShopState> emit) async {
    emit(ShopLoading());
    try {
      final result = await getShopUseCase(NoParams());
      result.fold(
        (failure) => emit(ShopError(failure.message)),
        (shop) => emit(ShopLoaded(shop)),
      );
    } catch (e) {
      // Catch unexpected exceptions and emit an error state so the UI can react
      emit(ShopError('Failed to load shop: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateShop(
      UpdateShopEvent event, Emitter<ShopState> emit) async {
    emit(ShopLoading());
    try {
      final result = await updateShopUseCase(event.shop);
      result.fold(
        (failure) => emit(ShopError(failure.message)),
        (_) {
          // Emit success then reload the latest shop data
          emit(ShopOperationSuccess());
          add(LoadShopEvent());
        },
      );
    } catch (e) {
      emit(ShopError('Failed to update shop: ${e.toString()}'));
    }
  }
}
