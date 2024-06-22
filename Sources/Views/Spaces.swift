#if os(WASI)
public enum Space: View {
 case horizontal(Double), vertical(Double)
 public var body: some View {
  AnyView(
   Group {
    switch self {
    case .horizontal(let width): HStack { Spacer() }.frame(width: width)
    case .vertical(let height): VStack { Spacer() }.frame(height: height)
    }
   }
  )
 }
}

public extension Space {
 enum Flexible: View {
  case horizontal, vertical
  public var body: some View {
   AnyView(
    Group {
     switch self {
     case .horizontal:
      HStack { Spacer() }
     case .vertical:
      VStack { Spacer() }
     }
    }
   )
  }
 }
}
#endif
