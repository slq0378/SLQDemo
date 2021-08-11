//
//  WidgetExtension.swift
//  WidgetExtension
//
//  Created by hz on 2021/8/10.
//  Copyright © 2021 难说再见了. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents

// 控制器，类似Controller，这里可以用来做小组件的刷新操作
struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// 数据模型，数据显示在View上必须经过这里
struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

// View，小组件的界面
struct WidgetExtensionEntryView : View {
    @Environment(\.widgetFamily) var family:WidgetFamily
    var entry: Provider.Entry
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            // 深度布局，屏幕深度
            ZStack(alignment: .center, content: {
                // 背景图
                Image("2").resizable().aspectRatio(contentMode: .fill)
                //  水平
                HStack(alignment: .center, spacing: 5, content: {
                    // 左侧图
                    Image("1").frame(width: 80, height: 80, alignment: .center).aspectRatio(contentMode: .fit).cornerRadius(10.0)
                    // 垂直
                    VStack(alignment: .center, spacing: 5, content: {
                        // 右侧文字
                        Text("小组件1").foregroundColor(.blue)
                        Text("小组件2").foregroundColor(.blue).lineLimit(2)
                    })

                })
            }).widgetURL(URL(string: "widgetExtensionDemo://test1"))
        case .systemMedium:
            // 深度布局，屏幕深度
            ZStack(alignment: .center, content: {
                // 背景图
                Image("2").resizable().aspectRatio(contentMode: .fill)
                //  水平
                HStack(alignment: .top, spacing: 5, content: {
                    // 左侧图
                    Image("1").resizable().aspectRatio(contentMode: .fit).frame(width: 200, height: 80, alignment: .leading).cornerRadius(10.0).foregroundColor(.blue)
                    // 垂直
                    VStack(alignment: .trailing, spacing: 5, content: {
                        // 右侧文字
                        Text("zh组件1").foregroundColor(.blue)
                        Text("小组件2").foregroundColor(.blue).lineLimit(2)
                    }).foregroundColor(.gray)

                })
            }).widgetURL(URL(string: "widgetExtensionDemo://test2"))
        case .systemLarge:
            // 深度布局，屏幕深度
            ZStack(alignment: .center, content: {
                // 背景图
                Image("2").resizable().aspectRatio(contentMode: .fill)
                //  水平
                HStack(alignment: .center, spacing: 5, content: {
                    // 左侧图
                    Image("1").aspectRatio(contentMode: .fit).cornerRadius(10.0).frame(width: 200, height: 100, alignment: .leading)
                    // 垂直
                    VStack(alignment: .center, spacing: 5, content: {
                        // 右侧文字
                        Text("小组件1").foregroundColor(.blue)
                        Text("小组件2").foregroundColor(.blue).lineLimit(2)
                    })

                }).foregroundColor(.blue)
            }).widgetURL(URL(string: "widgetExtensionDemo://test3"))
            
        default:
            // 深度布局，屏幕深度
            ZStack(alignment: .center, content: {
                // 背景图
                Image("2").resizable().aspectRatio(contentMode: .fit)
                //  水平
                HStack(alignment: .center, spacing: 5, content: {
                    // 左侧图
                    Image("1").frame(width: 80, height: 80, alignment: .center).aspectRatio(contentMode: .fit).cornerRadius(10.0)
                    // 垂直
                    VStack(alignment: .center, spacing: 5, content: {
                        // 右侧文字
                        Text("小组件1").foregroundColor(.blue)
                        Text("小组件2").foregroundColor(.blue).lineLimit(2)
                    })

                })
            }).widgetURL(URL(string: "widgetExtensionDemo://test1"))
        }

    }
}

// 程序入口，初始化相关信息，如Provider，View等
//@main
struct WidgetExtension: Widget {
    let kind: String = "WidgetExtension"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WidgetExtensionEntryView(entry: entry)
        }
        .configurationDisplayName("小组件")
        .description("This is an 测试一下 widget.")
    }
}
// 自定义样式
struct WidgetExtension_Previews: PreviewProvider {
    static var previews: some View {
        
        // 设置小组件尺寸 systemSmall systemMedium systemLarge
        WidgetExtensionEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

// 更多小组件
@main
struct Widgets:WidgetBundle {
    init() {
        
    }

    @WidgetBundleBuilder
    var body: some Widget{ // 最多创建5次，也就是15个小组件
        WidgetExtension()
        CustomWidget()
        CustomWidget()
        CustomWidget()
        CustomWidget()
    }
    
}

struct CustomWidget:Widget {
    var kind:String="自定义组件"
    var body: some WidgetConfiguration{
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            CustomEntryView(entry:entry)
        }
        .configurationDisplayName("自定义更多组件")
        .description("ios14自定义更多小组件")
    }
    
}
// 自定义Ui
struct CustomEntryView:View {
    @Environment(\.widgetFamily) var family:WidgetFamily
    var entry: Provider.Entry
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            // 深度布局，屏幕深度
            ZStack(alignment: .center, content: {
                // 背景图
                Image("2").resizable().aspectRatio(contentMode: .fill)
                //  水平
                HStack(alignment: .center, spacing: 5, content: {
                    // 左侧图
                    Image("1").frame(width: 80, height: 80, alignment: .center).aspectRatio(contentMode: .fit).cornerRadius(10.0)
                    // 垂直
                    VStack(alignment: .center, spacing: 5, content: {
                        // 右侧文字
                        Text("小组件1").foregroundColor(.blue)
                        Text("小组件2").foregroundColor(.blue).lineLimit(2)
                    })

                })
            }).widgetURL(URL(string: "widgetExtensionDemo://test1"))
        case .systemMedium:
            // 深度布局，屏幕深度
            ZStack(alignment: .center, content: {
                // 背景图
                Image("2").resizable().aspectRatio(contentMode: .fill)
                //  水平
                HStack(alignment: .top, spacing: 5, content: {
                    // 左侧图
                    Image("1").resizable().aspectRatio(contentMode: .fit).frame(width: 200, height: 80, alignment: .leading).cornerRadius(10.0).foregroundColor(.blue)
                    // 垂直
                    VStack(alignment: .trailing, spacing: 5, content: {
                        // 右侧文字
                        Text("zh组件1").foregroundColor(.blue)
                        Text("小组件2").foregroundColor(.blue).lineLimit(2)
                    }).foregroundColor(.gray)

                })
            }).widgetURL(URL(string: "widgetExtensionDemo://test2"))
        case .systemLarge:
            // 深度布局，屏幕深度
            ZStack(alignment: .center, content: {
                // 背景图
                Image("2").resizable().aspectRatio(contentMode: .fill)
                //  水平
                HStack(alignment: .center, spacing: 5, content: {
                    // 左侧图
                    Image("1").aspectRatio(contentMode: .fit).cornerRadius(10.0).frame(width: 200, height: 100, alignment: .leading)
                    // 垂直
                    VStack(alignment: .center, spacing: 5, content: {
                        // 右侧文字
                        Text("小组件1").foregroundColor(.blue)
                        Text("小组件2").foregroundColor(.blue).lineLimit(2)
                    })

                }).foregroundColor(.blue)
            }).widgetURL(URL(string: "widgetExtensionDemo://test3"))
            
        default:
            // 深度布局，屏幕深度
            ZStack(alignment: .center, content: {
                // 背景图
                Image("2").resizable().aspectRatio(contentMode: .fit)
                //  水平
                HStack(alignment: .center, spacing: 5, content: {
                    // 左侧图
                    Image("1").frame(width: 80, height: 80, alignment: .center).aspectRatio(contentMode: .fit).cornerRadius(10.0)
                    // 垂直
                    VStack(alignment: .center, spacing: 5, content: {
                        // 右侧文字
                        Text("小组件1").foregroundColor(.blue)
                        Text("小组件2").foregroundColor(.blue).lineLimit(2)
                    })

                })
            }).widgetURL(URL(string: "widgetExtensionDemo://test1"))
        }

    }
}
