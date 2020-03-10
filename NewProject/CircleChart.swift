//
//  CircleView.swift
//  KlassTimer
//
//  Created by Bui Quoc Viet on 2/15/20.
//  Copyright © 2020 ClassiOS. All rights reserved.
//

import Foundation
import UIKit
import Darwin 

struct Arc {
    var from: CGFloat;
    var to: CGFloat;
}

class CircleChart : UIView{
    private let START = -CGFloat.pi / 2;
    private let END =  -CGFloat.pi / 2 + CGFloat.pi * 2;
    private let CIRCLE_RADIUS = 2 * CGFloat.pi;
    private let R_SATELLITE = 10 * 1.5;
    private var centerPoint: CGPoint!;
    private let WIDTH_ARC = 40;
    private let MIN_SAPCE_BETWEEN_SATELLITE = 1.0;
    
    private var rPercent: CGFloat!;
    private var R: CGFloat!
    private var r: CGFloat!
    private var total: CGFloat! = nil;
    private var unit: CGFloat!;
    private var sinAlpha: CGFloat!
    private var cosAlpha: CGFloat!;
    
    private var data: [CGFloat]! = nil;
    private var listArc: [Arc] = [];
    private var listPointOfBigCircle: [CGPoint] = [];
    private var listPointOfSatellite: [CGPoint] = [];
    private var listPointPercent: [CGPoint] = [];
    
    override func draw(_ rect: CGRect) {
        self.centerPoint = CGPoint.init(x: rect.width/2.0, y: rect.height/2.0)
        self.rPercent = CGFloat(rect.width / 2 * 0.9);
        self.R = self.rPercent * 0.8;
        self.r = self.R * 0.5;
        
        self.sinAlpha = getSinAlpha(R: self.R, rOfSatellite: CGFloat(self.R_SATELLITE + self.MIN_SAPCE_BETWEEN_SATELLITE))
        self.cosAlpha = getCosAlpha(R: self.R, rOfSatellite: CGFloat(self.R_SATELLITE + self.MIN_SAPCE_BETWEEN_SATELLITE))
    }
    
    public func drawArcs() {
        var from = self.START
        for index in 0 ... (data.count - 1) {
            let to = from + data[index] * self.unit;

            self.drawArc(from: from, to: to, color: MyColor.listColor[index], radius: self.r)
            self.listArc.append(Arc(from: from, to: to))
            from = to;
        }
    }
    
    public func drawSmallData() {
           self.getListPoint();
           self.updateListPoint();
           
           for index in 0 ... self.listPointOfBigCircle.count - 1 {
               let point = self.listPointOfBigCircle[index]
               let color = MyColor.listColor[index];
               let percent = data[index] * (100 / self.total);
               let percentPoint = self.listPointPercent[index];
               
               self.drawSatellite(centerPoint: point, color: color);
               self.drawLine(from: self.listPointOfSatellite[index], to: point, color: color)
               
               self.drawLable(percent: percent, point: percentPoint, color: color)
           }
       }
       
    func drawLine(from: CGPoint, to: CGPoint, color: UIColor) {
       let aPath = UIBezierPath()
       aPath.move(to: from)
       aPath.addLine(to: to)
       aPath.close()
       color.set()
       aPath.stroke()
       aPath.fill()
       
       let shape = CAShapeLayer();
       shape.path = aPath.cgPath;
       shape.lineWidth = 2;
       shape.strokeColor = color.cgColor;
       
       self.layer.addSublayer(shape)
    }
    
    public func addData(data: [CGFloat]) {
        self.total = 0;
        self.listArc = [];
        
        self.data = data;
        self.data.sort();
        
        for i in data {
            self.total += i;
        }
        
        self.unit = CGFloat(2 * .pi / self.total);
    }
    
    public func resetChart() {
        if let sublayers = self.layer.sublayers {
            for element in sublayers {
                element.removeFromSuperlayer()
            }
        }
        
        for element in subviews {
            self.willRemoveSubview(element)
        }
                
        self.data = [];
        self.listPointPercent = [];
        self.listArc = [];
        self.listPointOfBigCircle = [];
        self.listPointOfSatellite = [];
        self.total = 0;
        self.unit = 0;
    }
     
    private func drawArc (from: CGFloat, to: CGFloat, color: UIColor, radius: CGFloat){
        let path: UIBezierPath = UIBezierPath(arcCenter: self.centerPoint, radius: radius, startAngle: from, endAngle: to, clockwise: true)
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = CGFloat(self.WIDTH_ARC);
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.path = path.cgPath;
        
        self.layer.addSublayer(shapeLayer)
    }
    
    private func drawSatellite (centerPoint: CGPoint, color: UIColor) {
        
        let path: UIBezierPath = UIBezierPath(arcCenter: centerPoint, radius: CGFloat(self.R_SATELLITE), startAngle: self.START, endAngle: self.END, clockwise: true)
        let shapeLayer = CAShapeLayer()
        
        shapeLayer.fillColor = color.cgColor
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.path = path.cgPath;
        self.layer.addSublayer(shapeLayer)
    }
    
    private func getListPoint() {
        let pointOfBigCircle = CGPoint(x: self.centerPoint.x, y: self.centerPoint.y - CGFloat(R))
        let pointOfSatellite = CGPoint(x: self.centerPoint.x, y: self.centerPoint.y - CGFloat(r + 20))
        let pointOfPercent = CGPoint(x: self.centerPoint.x, y: self.centerPoint.y - CGFloat(self.rPercent))
        
        for index in 0 ... listArc.count - 1 {
            let arc = listArc[index]
            let alpha = 0 - self.START + arc.from + (arc.to - arc.from) / 2.0 ;

            let newPointOfBigCircle = generateNewPoint(point: pointOfBigCircle, alpha: alpha);
            let newPointOfSmallCircle = generateNewPoint(point: pointOfSatellite, alpha: alpha);
            let newPointOfPercent = generateNewPoint(point: pointOfPercent, alpha: alpha)

            self.listPointOfBigCircle.append(newPointOfBigCircle);
            self.listPointOfSatellite.append(newPointOfSmallCircle);
            self.listPointPercent.append(newPointOfPercent);
        }
    
    }
    
    private func spaceBeteewnPoint(x: CGPoint, y: CGPoint) -> CGFloat{
        return CGFloat(sqrt(pow(y.x - x.x, 2) + pow(y.y - x.y, 2)))
    }
    
    private func updateListPoint() {
        for index in 0 ... self.listPointOfBigCircle.count - 2 {
            let point = self.listPointOfBigCircle[index];
            let nextPoint = self.listPointOfBigCircle[index + 1];
            let spaceBeteewn = self.spaceBeteewnPoint(x: point, y: nextPoint)

            if isSatelliteOverlap(space: spaceBeteewn) {
                let pointOfPercent = self.listPointPercent[index];
                
                let newPointOfPercent = generateNewPoint(point: pointOfPercent, cosAlpha: self.cosAlpha, sinAlpha: sinAlpha);
                let newNexPoint = generateNewPoint(point: point, cosAlpha: self.cosAlpha, sinAlpha: sinAlpha);
                
                self.listPointOfBigCircle[index + 1] = newNexPoint;
                self.listPointPercent[index + 1] = newPointOfPercent;
            }
        }
    }
    
    private func isSatelliteOverlap(space: CGFloat) -> Bool {
        return space < CGFloat(2 * self.R_SATELLITE + self.MIN_SAPCE_BETWEEN_SATELLITE)
        || space == CGFloat(2 * self.R_SATELLITE + self.MIN_SAPCE_BETWEEN_SATELLITE)
    }
    
    private func getSinAlpha(R: CGFloat, rOfSatellite: CGFloat) -> CGFloat {
        let sinAlpha = 2 * (rOfSatellite / R) * (sqrt(R * R - rOfSatellite * rOfSatellite) / R);
        return CGFloat(sinAlpha);
    }
    
    private func getCosAlpha(R: CGFloat, rOfSatellite: CGFloat) -> CGFloat {
        let cos = 1 - 2 * (rOfSatellite / R) * (rOfSatellite / R);
        return cos;
    }
    
    func generateNewPoint (point: CGPoint, alpha: CGFloat) -> CGPoint {
        let x: CGFloat = self.centerPoint.x + (point.x - self.centerPoint.x) * cos(alpha) - (point.y - self.centerPoint.y) * sin(alpha)
        let y: CGFloat = self.centerPoint.y + (point.x - self.centerPoint.x) * sin(alpha) + (point.y - self.centerPoint.y) * cos(alpha)
        return CGPoint(x: x, y: y)
    }
    
    func generateNewPoint (point : CGPoint,cosAlpha: CGFloat, sinAlpha: CGFloat) -> CGPoint {
        let x: CGFloat = self.centerPoint.x + (point.x - self.centerPoint.x) * cosAlpha - (point.y - self.centerPoint.y) * sinAlpha
        let y: CGFloat = self.centerPoint.y + (point.x - self.centerPoint.x) * sinAlpha + (point.y - self.centerPoint.y) * cosAlpha
        return CGPoint(x: x, y: y)
    }
    
    func drawLable(percent: CGFloat, point: CGPoint, color: UIColor) {
        let label : UILabel = UILabel();
        label.frame.size = CGSize(width: 3 * self.R_SATELLITE, height: 2 * self.R_SATELLITE)
        label.center = point
        label.font = UIFont(name: label.font!.fontName, size: 10)
        label.text = String.init(format: "%.02f%%", percent);
        label.textAlignment  = .center
        label.textColor = color
        self.addSubview(label)
    }
    
    public func drawCircleAlpha4 () {
        let radius = self.r - CGFloat(WIDTH_ARC / 4)
        let path: UIBezierPath = UIBezierPath(arcCenter: self.centerPoint, radius: radius, startAngle: self.START, endAngle: self.END, clockwise: true)
        let shapeLayer = CAShapeLayer()

        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.lineWidth = CGFloat(WIDTH_ARC / 2);
        shapeLayer.strokeColor = UIColor.gray.cgColor
        shapeLayer.path = path.cgPath;
        shapeLayer.opacity = 0.6
        
        self.layer.addSublayer(shapeLayer)
    }
}
