import {
  requireNativeComponent,
  UIManager,
  Platform,
  type ViewStyle,
  type TextStyle,
} from 'react-native';

const LINKING_ERROR =
  "The package 'dragon-family-counter-component' doesn't seem to be linked. Make sure: \n\n" +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

type DragonFamilyCounterComponentProps = {
  initialAnimationDuration?: number; // Скорость начальной анимации (в миллисекундах)
  thousandsSeparatorSpacing?: number; // Скорость начальной анимации (в миллисекундах)
  color?: string; // Цвет текста счётчика
  fontSize?: number; // Размер шрифта счётчика
  initialValue?: number; // Начальное значение счётчика
  limit?: number; // Ограничение счетчика
  timeInterval?: number; // Ограничение счетчика
  countOfRubiesInInterval?: number; // Ограничение счетчика
  onLimitReached?: (value: number) => void;
  textStyle?: TextStyle; // Стиль текста, включающий такие параметры, как fontFamily, fontWeight и т. д.
  style?: ViewStyle; // Стиль компонента
};

const ComponentName = 'DragonFamilyCounterComponentView';

// Проверка подключения компонента
export const DragonFamilyCounterComponentView =
  UIManager.getViewManagerConfig(ComponentName) != null
    ? requireNativeComponent<DragonFamilyCounterComponentProps>(ComponentName)
    : () => {
        throw new Error(LINKING_ERROR);
      };
