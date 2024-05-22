import SwiftUI

@available(iOS 15, *)
struct CardView: View
{
    @ObservedObject var config: Configuration
    @ObservedObject var engagementManager: EngagementManager
    @StateObject private var viewModel: ViewModel
    let isLast: Bool
    
    var body: some View
    {
        if let template = viewModel.getCardTemplate(from: "templateData")
        {
            VStack(alignment: .leading, spacing: 0)
            {
                if let imageUrl = template.image
                {
                    
                    AsyncImage(url: URL(string: imageUrl))
                    { image in
                        
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .overlay(.black.opacity(0.4))
                        
                    } placeholder: {ProgressView().progressViewStyle(.circular) }
                }
                        Text(template.title ?? "")
                            .foregroundStyle(.black)
                            .padding()
                    
                if let buttons = template.buttons
                {
                    HStack
                    {
                        ForEach(0..<buttons.count, id: \.self)
                        { index in
                            
                            if index == 0
                            {
                                Spacer()
                            }
                            
                            Button(buttons[index].title)
                            {
                                viewModel.sendInput(for: buttons[index])
                            }
                            .buttonStyle(.borderless)
                            .tint(engagementManager.settings?.actionColor)
                            
                            if index == buttons.count - 1
                            {
                                Spacer()
                            }
                        }
                    }
                    .padding([.horizontal, .bottom])
                }
                
                if let rows = template.rows
                {
                    VStack
                    {
                        ForEach(0..<rows.count, id: \.self)
                        { index in
                            
                            HStack
                            {
                                Text(rows[index].title)
                                Spacer(minLength: 6)
                                Text(rows[index].value)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
            
            if let cards = template.cards, template.type == .cardList
            {
                ForEach(0..<cards.count, id: \.self)
                { index in
                    
                    if(cards[index].isVisible ?? true) {
                        VStack(alignment: .leading, spacing: 0)
                        {
                            if let imageUrl = cards[index].image
                            {
                                AsyncImage(url: URL(string: imageUrl))
{ image in
                                    
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                    
                                } placeholder: {ProgressView().progressViewStyle(.circular) }
                            }
                            
                            if let title = cards[index].title
                            {
                                Text(title)
                                    .bold()
                            }
                            
                            if let rows = cards[index].rows
                            {
                                
                                
                                VStack
                                {
                                    ForEach(0..<rows.count, id: \.self)
                                    { index in
                                        
                                        HStack
                                        {
                                            Text(rows[index].title)
                                            Spacer()
                                            Text(rows[index].value)
                                        }
                                    }
                                }
                                .padding([.vertical])
                                
                            }
                            
                            if let buttons = cards[index].buttons
                            {
                                HStack
                                {
                                    ForEach(0..<buttons.count, id: \.self)
                                    { index in
                                        
                                        if index == 0
                                        {
                                           Spacer()
                                        }
                                        
                                        Button(buttons[index].title)
                                        {
                                            viewModel.sendInput(for: buttons[index])
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .tint(engagementManager.settings?.actionColor)
                                        .alert(viewModel.message, isPresented: $viewModel.showMessage) {
                                            Button("OK", role: .cancel) {}
                                        }
                                        
                                            if index == buttons.count - 1
                                            {
                                                Spacer()
                                            }
                                        }
                                    }
                                    .padding([.horizontal])
                                }
                            }
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding([.top])
                        }
                    }
                }
            }

        }
        
    init(config: Configuration, engagementManager: EngagementManager, event: ConversationEvent, isLast: Bool)
        {
            self.config = config
            self.engagementManager = engagementManager
            self.isLast = isLast
            
            _viewModel = StateObject(wrappedValue: ViewModel(config: config, manager: engagementManager, event: event))
        }
    }
