//
//  OfferCell.swift
//  Ofertapp
//
//  Created by Ernesto Fdez on 2/4/16.
//  Copyright © 2016 AE. All rights reserved.
//

import UIKit

class OffersTableCell: UITableViewCell {
    
    @IBOutlet weak var imageField: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var fechaInicioLabel: UILabel!
    @IBOutlet weak var fechaFinLabel: UILabel!
    @IBOutlet weak var validationImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}