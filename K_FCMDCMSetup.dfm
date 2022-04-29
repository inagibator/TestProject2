inherited K_FormCMDCMSetup: TK_FormCMDCMSetup
  Left = 353
  Top = 259
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'DICOM configuration settings'
  ClientHeight = 440
  ClientWidth = 676
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 664
    Top = 427
  end
  object BtOK: TButton
    Left = 527
    Top = 409
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object BtCancel: TButton
    Left = 599
    Top = 409
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 676
    Height = 399
    ActivePage = TSQR
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 3
    object TSGeneral: TTabSheet
      Caption = 'General'
      ImageIndex = 1
      DesignSize = (
        668
        371)
      object ChBCommitment: TCheckBox
        Left = 11
        Top = 40
        Width = 639
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'DICOM Store Commitment'
        TabOrder = 0
      end
      object ChBDCMAutoStore: TCheckBox
        Left = 11
        Top = 16
        Width = 639
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Automatic DICOM Store'
        TabOrder = 1
      end
    end
    object TSQR: TTabSheet
      Caption = 'Network'
      DesignSize = (
        668
        371)
      object BtConnect: TButton
        Left = 326
        Top = 336
        Width = 97
        Height = 23
        Caption = 'Test connections'
        TabOrder = 0
        OnClick = BtConnectClick
      end
      object GBStore: TGroupBox
        Left = 7
        Top = 72
        Width = 652
        Height = 57
        Anchors = [akLeft, akTop, akRight]
        Caption = '   Store                                 '
        TabOrder = 1
        object Label8: TLabel
          Left = 488
          Top = 24
          Width = 74
          Height = 13
          Caption = 'Calling AE Title:'
        end
        object ShapeStoreState: TShape
          Left = 120
          Top = 0
          Width = 16
          Height = 16
          Brush.Color = clGray
          Pen.Color = clGreen
          Shape = stCircle
        end
        object LbStoreAetScu: TLabel
          Left = 568
          Top = 24
          Width = 74
          Height = 13
          Caption = '_AE_________'
        end
        object LEStoreIPAddr: TLabeledEdit
          Left = 232
          Top = 20
          Width = 105
          Height = 21
          Color = 10682367
          EditLabel.Width = 57
          EditLabel.Height = 13
          EditLabel.Caption = 'IP Address: '
          LabelPosition = lpLeft
          TabOrder = 0
          OnChange = LEdServerNameChange
        end
        object LEStorePortNum: TLabeledEdit
          Left = 419
          Top = 20
          Width = 54
          Height = 21
          Color = 10682367
          EditLabel.Width = 65
          EditLabel.Height = 13
          EditLabel.Caption = 'Port Number: '
          LabelPosition = lpLeft
          TabOrder = 1
          OnChange = LEdPortChange
        end
        object LEStorePACSAet: TLabeledEdit
          Left = 67
          Top = 20
          Width = 86
          Height = 21
          Color = 10682367
          EditLabel.Width = 58
          EditLabel.Height = 13
          EditLabel.Caption = 'PACS AET: '
          LabelPosition = lpLeft
          TabOrder = 2
          OnChange = LEdServerNameChange
        end
      end
      object GBQR: TGroupBox
        Left = 7
        Top = 8
        Width = 652
        Height = 57
        Anchors = [akLeft, akTop, akRight]
        Caption = '   Query/Retrieve                 '
        TabOrder = 2
        object Label1: TLabel
          Left = 488
          Top = 24
          Width = 74
          Height = 13
          Caption = 'Calling AE Title:'
        end
        object ShapeQRState: TShape
          Left = 120
          Top = 0
          Width = 16
          Height = 16
          Brush.Color = clGray
          Pen.Color = clGreen
          Shape = stCircle
        end
        object LbQRAetScu: TLabel
          Left = 568
          Top = 24
          Width = 74
          Height = 13
          Caption = '_AE_________'
        end
        object LEQRIPAddr: TLabeledEdit
          Left = 232
          Top = 20
          Width = 105
          Height = 21
          Color = 10682367
          EditLabel.Width = 57
          EditLabel.Height = 13
          EditLabel.Caption = 'IP Address: '
          LabelPosition = lpLeft
          TabOrder = 0
          OnChange = LEdServerNameChange
        end
        object LEQRPortNum: TLabeledEdit
          Left = 419
          Top = 20
          Width = 54
          Height = 21
          Color = 10682367
          EditLabel.Width = 65
          EditLabel.Height = 13
          EditLabel.Caption = 'Port Number: '
          LabelPosition = lpLeft
          TabOrder = 1
          OnChange = LEdPortChange
        end
        object LEQRPACSAet: TLabeledEdit
          Left = 67
          Top = 20
          Width = 86
          Height = 21
          Color = 10682367
          EditLabel.Width = 58
          EditLabel.Height = 13
          EditLabel.Caption = 'PACS AET: '
          LabelPosition = lpLeft
          TabOrder = 2
          OnChange = LEdServerNameChange
        end
      end
      object GBSComm: TGroupBox
        Left = 7
        Top = 136
        Width = 652
        Height = 57
        Anchors = [akLeft, akTop, akRight]
        Caption = '   Storage Commitment         '
        TabOrder = 3
        object Label3: TLabel
          Left = 488
          Top = 24
          Width = 74
          Height = 13
          Caption = 'Calling AE Title:'
        end
        object ShapeSCommState: TShape
          Left = 120
          Top = 0
          Width = 16
          Height = 16
          Brush.Color = clGray
          Pen.Color = clGreen
          Shape = stCircle
        end
        object LbSCommAetScu: TLabel
          Left = 568
          Top = 24
          Width = 74
          Height = 13
          Caption = '_AE_________'
        end
        object LESCommIPAddr: TLabeledEdit
          Left = 232
          Top = 20
          Width = 105
          Height = 21
          Color = 10682367
          EditLabel.Width = 57
          EditLabel.Height = 13
          EditLabel.Caption = 'IP Address: '
          LabelPosition = lpLeft
          TabOrder = 0
          OnChange = LEdServerNameChange
        end
        object LESCommPortNum: TLabeledEdit
          Left = 419
          Top = 20
          Width = 54
          Height = 21
          Color = 10682367
          EditLabel.Width = 65
          EditLabel.Height = 13
          EditLabel.Caption = 'Port Number: '
          LabelPosition = lpLeft
          TabOrder = 1
          OnChange = LEdPortChange
        end
        object LESCommPACSAet: TLabeledEdit
          Left = 67
          Top = 20
          Width = 86
          Height = 21
          Color = 10682367
          EditLabel.Width = 58
          EditLabel.Height = 13
          EditLabel.Caption = 'PACS AET: '
          LabelPosition = lpLeft
          TabOrder = 2
          OnChange = LEdServerNameChange
        end
      end
      object GBMWL: TGroupBox
        Left = 7
        Top = 200
        Width = 652
        Height = 57
        Anchors = [akLeft, akTop, akRight]
        Caption = '   MWL                                 '
        TabOrder = 4
        object Label5: TLabel
          Left = 488
          Top = 24
          Width = 74
          Height = 13
          Caption = 'Calling AE Title:'
        end
        object ShapeMWLState: TShape
          Left = 120
          Top = 0
          Width = 16
          Height = 16
          Brush.Color = clGray
          Pen.Color = clGreen
          Shape = stCircle
        end
        object LbMWLAetScu: TLabel
          Left = 568
          Top = 24
          Width = 74
          Height = 13
          Caption = '_AE_________'
        end
        object LEMWLIPAddr: TLabeledEdit
          Left = 232
          Top = 20
          Width = 105
          Height = 21
          Color = 10682367
          EditLabel.Width = 57
          EditLabel.Height = 13
          EditLabel.Caption = 'IP Address: '
          LabelPosition = lpLeft
          TabOrder = 0
          OnChange = LEdServerNameChange
        end
        object LEMWLPortNum: TLabeledEdit
          Left = 419
          Top = 20
          Width = 54
          Height = 21
          Color = 10682367
          EditLabel.Width = 65
          EditLabel.Height = 13
          EditLabel.Caption = 'Port Number: '
          LabelPosition = lpLeft
          TabOrder = 1
          OnChange = LEdPortChange
        end
        object LEMWLPACSAet: TLabeledEdit
          Left = 67
          Top = 20
          Width = 86
          Height = 21
          Color = 10682367
          EditLabel.Width = 58
          EditLabel.Height = 13
          EditLabel.Caption = 'PACS AET: '
          LabelPosition = lpLeft
          TabOrder = 2
          OnChange = LEdServerNameChange
        end
      end
      object ChBUseSameAttrs: TCheckBox
        Left = 8
        Top = 341
        Width = 161
        Height = 17
        Caption = 'Use for all DICOM services'
        TabOrder = 5
        OnClick = ChBUseSameAttrsClick
      end
      object GBAetScu: TGroupBox
        Left = 7
        Top = 264
        Width = 652
        Height = 57
        Caption = '   Applicatiom Entity Title of Service Class User  '
        TabOrder = 6
        object LEAetStoreSCP: TLabeledEdit
          Left = 456
          Top = 20
          Width = 105
          Height = 21
          Color = 10682367
          EditLabel.Width = 58
          EditLabel.Height = 13
          EditLabel.Caption = 'StoreSCP:   '
          LabelPosition = lpLeft
          TabOrder = 0
          OnChange = LEdServerNameChange
        end
        object LEAetCMSuite: TLabeledEdit
          Left = 155
          Top = 20
          Width = 102
          Height = 21
          Color = 10682367
          EditLabel.Width = 112
          EditLabel.Height = 13
          EditLabel.Caption = 'CMSuite/CMDCM:        '
          LabelPosition = lpLeft
          TabOrder = 1
          Text = 'Mediasuite'
          OnChange = LEdServerNameChange
        end
      end
    end
  end
end
