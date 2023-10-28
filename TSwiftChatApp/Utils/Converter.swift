//
//  Converter.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 28/09/2023.
//

import Foundation


func convertDate(_ date: Date) -> String {
    let calendar = Calendar.current
    let now = Date()
    
    // Tính khoảng cách thời gian giữa date và ngày hiện tại
    let timeDifference = calendar.dateComponents([.day, .weekOfYear], from: date, to: now)
    let dateFormatter = DateFormatter()
    
    if timeDifference.day == 0 {
        // Nếu date là trong ngày, hiển thị giờ
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date)
    } else if timeDifference.weekOfYear == 0 {
        // Nếu date > 1 ngày và < 1 tuần, hiển thị thứ
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.string(from: date)
    } else {
        // Nếu date > 1 tuần, hiển thị ngày tháng
        return date.longDate()
    }
}

func isNotTheSameDate(date1 : Date, date2:  Date) ->Bool{
    let distance = Calendar.current.dateComponents([.day], from: date1, to: date2).day
    return abs(distance ?? 2) > 1
}
