import SwiftUI

struct LoadingView: View
{
    var body: some View
    {
        HStack(alignment: .center)
        {
            Spacer()
            ProgressView()
            Spacer()
        }
        .padding()
    }
}
