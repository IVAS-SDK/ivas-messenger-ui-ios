import SwiftUI

@available(iOS 15, *)
struct SurveyView: View
{
    @ObservedObject var config: Configuration
    @ObservedObject var engagementManager: EngagementManager
    @StateObject private var viewModel: ViewModel
    let isLast: Bool
    
    var body: some View
    {
        if let template = viewModel.getCardTemplate(from: "surveyData"), isLast
        {
            VStack(alignment: .leading, spacing: 0)
            {
                if let cards = template.cards, template.type == .cardList
                {
                    ForEach(0..<cards.count, id: \.self)
                    { index in
                        
                        if(cards[index].isVisible ?? true) {
                            VStack(alignment: .leading, spacing: 0)
                            {
                                
                                
                                if let title = cards[index].title
                                {
                                    Text(title)
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
                                            
                                            Button
                                            {
                                                viewModel.sendInput(for: buttons[index])
                                            } label: { Text(buttons[index].title).padding(.horizontal, 12).padding(.vertical, 6) }
                                            .buttonStyle(.borderedProminent)
                                            .tint(engagementManager.settings?.actionColor)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 12)
                                            
                                        }
                                    }
                                }
                            }
                            .padding(EdgeInsets(top: 0, leading: 64, bottom: 0, trailing: 64))
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .padding()
                        }
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
