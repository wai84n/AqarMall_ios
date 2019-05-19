//
//  ReceivedBidsCell.swift
//  AqarMall
//
//  Created by Macbookpro on 5/19/19.
//  Copyright © 2019 Macbookpro. All rights reserved.
//

import UIKit
protocol ReceivedBidsDelegate : class {
    func acceptBid(index: Int)
    func rejectBid(index: Int)
}


class ReceivedBidsCell: UITableViewCell {
    @IBOutlet weak var isApprovedLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var priceLable: UILabel!
    @IBOutlet weak var regDateLable: UILabel!
    
    var delegate : ReceivedBidsDelegate? = nil
    
    var section: Int = 0
    var index: Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update(with myBidAds: ReceivedBids, _index :Int) {
        self.index = _index
        
        if myBidAds.approved{
            isApprovedLabel.text = "مقبول"
        }else{
            isApprovedLabel.text = "لم يتم الرد عليها بعد"
        }
        messageLabel.text = myBidAds.message
        priceLable.text = "\(myBidAds.price)"
        regDateLable.text = myBidAds.regDate
    }
    
    @IBAction func acceptBidAction(_ sender: Any) {
        if let _delegate = delegate {
            _delegate.acceptBid(index: index)
        }
    }
    
    @IBAction func rejectBidAction(_ sender: Any) {
        if let _delegate = delegate {
            _delegate.rejectBid(index: index)
        }
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
