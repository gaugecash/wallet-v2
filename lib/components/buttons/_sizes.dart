enum GButtonSize { medium, large, small }

const buttonSizeMap = {
  GButtonSize.small: 42.0,
  GButtonSize.medium: 50.0,
  GButtonSize.large: 64.0,
};

extension SizeEnum on GButtonSize {
  double get size {
    return buttonSizeMap[this]!;
  }
}
