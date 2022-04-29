inherited K_FormCMDCMQR: TK_FormCMDCMQR
  Left = 348
  Top = 190
  Width = 766
  Height = 671
  Caption = 'DICOM Query/Retrieve'
  Constraints.MaxHeight = 671
  Constraints.MinHeight = 671
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 738
    Top = 620
  end
  object BtRetrieve: TButton
    Left = 589
    Top = 599
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Retrieve'
    Enabled = False
    TabOrder = 1
    OnClick = BtRetrieveClick
  end
  object BtCancel: TButton
    Left = 670
    Top = 599
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Close'
    ModalResult = 2
    TabOrder = 2
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 8
    Width = 734
    Height = 57
    Anchors = [akLeft, akTop, akRight]
    Caption = '  DICOM Server         '
    TabOrder = 3
    object Label7: TLabel
      Left = 8
      Top = 24
      Width = 58
      Height = 13
      Caption = 'PACS AET: '
    end
    object Label8: TLabel
      Left = 160
      Top = 24
      Width = 87
      Height = 13
      Caption = 'Server IP-address:'
    end
    object Label9: TLabel
      Left = 336
      Top = 24
      Width = 94
      Height = 13
      Caption = 'Server Port number:'
    end
    object Label10: TLabel
      Left = 488
      Top = 24
      Width = 74
      Height = 13
      Caption = 'Calling AE Title:'
    end
    object StateShape: TShape
      Left = 88
      Top = 0
      Width = 16
      Height = 16
      Brush.Color = clGray
      Pen.Color = clGreen
      Shape = stCircle
    end
    object LbServerPort: TLabel
      Left = 440
      Top = 24
      Width = 38
      Height = 13
      Caption = '_SP___'
    end
    object LbServerName: TLabel
      Left = 88
      Top = 24
      Width = 63
      Height = 13
      Caption = '_SN_______'
    end
    object LbServerIP: TLabel
      Left = 256
      Top = 24
      Width = 61
      Height = 13
      Caption = '_SI-__-__-__'
    end
    object LbAppEntity: TLabel
      Left = 568
      Top = 24
      Width = 110
      Height = 13
      Caption = '_AE_______________'
    end
  end
  object GroupBox4: TGroupBox
    Left = 8
    Top = 72
    Width = 734
    Height = 177
    Anchors = [akLeft, akTop, akRight]
    Caption = '   Query Patients   '
    TabOrder = 4
    DesignSize = (
      734
      177)
    object LEdPatName: TLabeledEdit
      Left = 93
      Top = 15
      Width = 291
      Height = 21
      Color = 10682367
      EditLabel.Width = 82
      EditLabel.Height = 13
      EditLabel.Caption = 'Patient Name:     '
      LabelPosition = lpLeft
      TabOrder = 0
    end
    object LEdPatID: TLabeledEdit
      Left = 93
      Top = 43
      Width = 291
      Height = 21
      Color = 10682367
      EditLabel.Width = 81
      EditLabel.Height = 13
      EditLabel.Caption = 'Patient Card No: '
      LabelPosition = lpLeft
      TabOrder = 1
    end
    object BtSelectAllPatients: TButton
      Left = 648
      Top = 106
      Width = 78
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Select All'
      Enabled = False
      TabOrder = 2
      OnClick = BtSelectAllPatientsClick
    end
    object BtResetPatients: TButton
      Left = 648
      Top = 74
      Width = 78
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Reset'
      TabOrder = 3
      OnClick = BtResetPatientsClick
    end
    object ListView1: TListView
      Left = 13
      Top = 77
      Width = 620
      Height = 92
      Anchors = [akLeft, akTop, akRight, akBottom]
      Checkboxes = True
      Columns = <
        item
          Caption = 'Patient ID'
          Width = 85
        end
        item
          Caption = 'Patient Surname'
          Width = 160
        end
        item
          Caption = 'Patient First name'
          Width = 160
        end
        item
          Caption = 'Patient DOB'
          Width = 75
        end
        item
          Alignment = taCenter
          Caption = 'Patient Gender'
          Width = 85
        end>
      ColumnClick = False
      GridLines = True
      ReadOnly = True
      TabOrder = 4
      ViewStyle = vsReport
      OnClick = ListView1Click
    end
    object BtQueryPatients: TButton
      Left = 648
      Top = 138
      Width = 78
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Query'
      Enabled = False
      TabOrder = 5
      OnClick = BtQueryPatientsClick
    end
  end
  object GroupBox5: TGroupBox
    Left = 8
    Top = 256
    Width = 734
    Height = 155
    Anchors = [akLeft, akTop, akRight]
    Caption = '   Query Studies   '
    TabOrder = 5
    DesignSize = (
      734
      155)
    object LbStudyDate: TLabel
      Left = 11
      Top = 25
      Width = 56
      Height = 13
      Caption = 'Study Date:'
    end
    object LbFrom: TLabel
      Left = 81
      Top = 25
      Width = 20
      Height = 13
      Caption = 'from'
    end
    object LbTo: TLabel
      Left = 215
      Top = 25
      Width = 9
      Height = 13
      Caption = 'to'
    end
    object DTPStFrom: TDateTimePicker
      Left = 109
      Top = 21
      Width = 99
      Height = 21
      Date = 39542.430481226850000000
      Format = 'dd/MM/yyyy'
      Time = 39542.430481226850000000
      ShowCheckbox = True
      Color = 10682367
      TabOrder = 0
      OnChange = DTPStFromChange
    end
    object DTPStTo: TDateTimePicker
      Left = 232
      Top = 21
      Width = 99
      Height = 21
      Date = 39542.430481226850000000
      Format = 'dd/MM/yyyy'
      Time = 39542.430481226850000000
      ShowCheckbox = True
      Color = 10682367
      TabOrder = 1
      OnChange = DTPStFromChange
    end
    object LEdANum: TLabeledEdit
      Left = 493
      Top = 20
      Width = 225
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = 10682367
      EditLabel.Width = 95
      EditLabel.Height = 13
      EditLabel.Caption = 'Accession Number: '
      LabelPosition = lpLeft
      TabOrder = 2
    end
    object ListView2: TListView
      Left = 13
      Top = 52
      Width = 623
      Height = 93
      Anchors = [akLeft, akTop, akRight, akBottom]
      Checkboxes = True
      Columns = <
        item
          Caption = 'Patient ID'
          Width = 80
        end
        item
          Caption = 'Study UID'
          Width = 400
        end
        item
          Caption = 'Study Date'
          Width = 65
        end
        item
          Caption = 'Study Time'
          Width = 65
        end>
      ColumnClick = False
      GridLines = True
      ReadOnly = True
      TabOrder = 3
      ViewStyle = vsReport
      OnClick = ListView2Click
    end
    object BtQueryStudies: TButton
      Left = 647
      Top = 114
      Width = 78
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Query'
      Enabled = False
      TabOrder = 4
      OnClick = BtQueryStudiesClick
    end
    object BtResetStudies: TButton
      Left = 647
      Top = 50
      Width = 78
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Reset'
      TabOrder = 5
      OnClick = BtResetStudiesClick
    end
    object BtSelectAllStudies: TButton
      Left = 648
      Top = 82
      Width = 78
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Select All'
      Enabled = False
      TabOrder = 6
      OnClick = BtSelectAllStudiesClick
    end
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 424
    Width = 734
    Height = 161
    Anchors = [akLeft, akTop, akRight]
    Caption = '   Query Series   '
    TabOrder = 6
    DesignSize = (
      734
      161)
    object BtQuerySeries: TButton
      Left = 644
      Top = 114
      Width = 78
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Query'
      Enabled = False
      TabOrder = 0
      OnClick = BtQuerySeriesClick
    end
    object LEdModality: TLabeledEdit
      Left = 61
      Top = 20
      Width = 137
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      Color = 10682367
      EditLabel.Width = 45
      EditLabel.Height = 13
      EditLabel.Caption = 'Modality: '
      LabelPosition = lpLeft
      TabOrder = 1
    end
    object ListView3: TListView
      Left = 13
      Top = 52
      Width = 621
      Height = 101
      Anchors = [akLeft, akTop, akRight, akBottom]
      Checkboxes = True
      Columns = <
        item
          Caption = 'Study UID'
          Width = 400
        end
        item
          Caption = 'Series Description'
          Width = 140
        end
        item
          Caption = 'Modality'
          Width = 60
        end>
      ColumnClick = False
      GridLines = True
      ReadOnly = True
      TabOrder = 2
      ViewStyle = vsReport
      OnClick = ListView3Click
    end
    object BtResetSeries: TButton
      Left = 644
      Top = 50
      Width = 78
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Reset'
      TabOrder = 3
      OnClick = BtResetSeriesClick
    end
    object BtSelectAllSeries: TButton
      Left = 644
      Top = 82
      Width = 78
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Select All'
      Enabled = False
      TabOrder = 4
      OnClick = BtSelectAllSeriesClick
    end
  end
end
