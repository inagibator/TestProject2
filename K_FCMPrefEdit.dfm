inherited K_FormPrefEdit: TK_FormPrefEdit
  Left = 431
  Top = 295
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Preferences'
  ClientHeight = 476
  ClientWidth = 732
  KeyPreview = True
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  inherited BFMinBRPanel: TPanel
    Left = 722
    Top = 466
    TabOrder = 3
  end
  object PageControl: TPageControl
    Left = 8
    Top = 0
    Width = 713
    Height = 425
    ActivePage = TSApplication
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
    object TSApplication: TTabSheet
      Caption = 'Application'
      DesignSize = (
        705
        397)
      object GBMTypes: TGroupBox
        Left = 493
        Top = 8
        Width = 198
        Height = 291
        Anchors = [akTop, akRight]
        Caption = '  Media Categories  '
        TabOrder = 0
        DesignSize = (
          198
          291)
        object LVMTypes: TListView
          Left = 9
          Top = 20
          Width = 178
          Height = 202
          Anchors = [akLeft, akTop, akRight, akBottom]
          Color = 10682367
          Columns = <
            item
              AutoSize = True
              Caption = 'A'
            end>
          HideSelection = False
          ReadOnly = True
          RowSelect = True
          ShowColumnHeaders = False
          TabOrder = 0
          ViewStyle = vsReport
          OnKeyDown = LVMTypesKeyDown
          OnSelectItem = LVMTypesSelectItem
        end
        object BtAdd: TButton
          Left = 25
          Top = 258
          Width = 64
          Height = 21
          Action = AddMType
          Anchors = [akRight, akBottom]
          TabOrder = 1
        end
        object BtDel: TButton
          Left = 108
          Top = 258
          Width = 61
          Height = 21
          Action = DelMType
          Anchors = [akRight, akBottom]
          TabOrder = 2
          OnEnter = BtDelEnter
        end
        object EdMTypeCName: TEdit
          Left = 9
          Top = 225
          Width = 178
          Height = 21
          Anchors = [akLeft, akRight, akBottom]
          Color = 10682367
          MaxLength = 25
          TabOrder = 3
          OnExit = EdMTypeCNameExit
          OnKeyDown = EdMTypeCNameKeyDown
        end
      end
      object RGToothNumbering: TRadioGroup
        Left = 272
        Top = 234
        Width = 211
        Height = 65
        Caption = '  Tooth Numbering  '
        ItemIndex = 0
        Items.Strings = (
          'F.D.I. Numbering System'
          'USA Numbering System')
        TabOrder = 1
      end
      object GBThumbTexts: TGroupBox
        Left = 16
        Top = 79
        Width = 245
        Height = 117
        Caption = '  Display on object icons  '
        TabOrder = 2
        object ChBDateTaken: TCheckBox
          Left = 16
          Top = 23
          Width = 217
          Height = 17
          Caption = 'Date object taken'
          TabOrder = 0
        end
        object ChBTimeTaken: TCheckBox
          Left = 16
          Top = 45
          Width = 217
          Height = 17
          Caption = 'Time object taken'
          TabOrder = 1
        end
        object ChBTeethChart: TCheckBox
          Left = 16
          Top = 67
          Width = 217
          Height = 17
          Caption = 'Teeth number on the dental chart'
          TabOrder = 2
        end
        object ChBMediaSource: TCheckBox
          Left = 16
          Top = 89
          Width = 217
          Height = 17
          Caption = 'Object source'
          TabOrder = 3
        end
      end
      object GBSmooth: TGroupBox
        Left = 16
        Top = 8
        Width = 245
        Height = 51
        Caption = '  Image display  '
        TabOrder = 3
        object ChBSmooth: TCheckBox
          Left = 16
          Top = 21
          Width = 217
          Height = 17
          Caption = 'Activate Windows Smoothing'
          TabOrder = 0
        end
      end
      object GBEEFilesNames: TGroupBox
        Left = 272
        Top = 8
        Width = 211
        Height = 217
        Caption = '  Names of exported objects  '
        TabOrder = 4
        object ChBEEPatSurname: TCheckBox
          Left = 16
          Top = 26
          Width = 171
          Height = 17
          Caption = 'Patient Surname'
          Checked = True
          Enabled = False
          State = cbChecked
          TabOrder = 0
        end
        object ChBEEPatFirstName: TCheckBox
          Left = 16
          Top = 48
          Width = 171
          Height = 17
          Caption = 'Patient First name'
          TabOrder = 1
        end
        object ChBEEPatTitle: TCheckBox
          Left = 16
          Top = 70
          Width = 171
          Height = 17
          Caption = 'Patient Title'
          TabOrder = 2
        end
        object ChBEEPatCardNum: TCheckBox
          Left = 16
          Top = 92
          Width = 171
          Height = 17
          Caption = 'Patient Card No'
          TabOrder = 3
        end
        object ChBEEObjDateTaken: TCheckBox
          Left = 16
          Top = 114
          Width = 171
          Height = 17
          Caption = 'Date object taken'
          TabOrder = 4
        end
        object ChBEEObjID: TCheckBox
          Left = 16
          Top = 136
          Width = 171
          Height = 17
          Caption = 'Object ID'
          Checked = True
          Enabled = False
          State = cbChecked
          TabOrder = 5
        end
        object ChBEEPatDOB: TCheckBox
          Left = 16
          Top = 158
          Width = 171
          Height = 17
          Caption = 'Patient DOB'
          TabOrder = 6
        end
        object ChBEEObjTeethChart: TCheckBox
          Left = 16
          Top = 180
          Width = 180
          Height = 17
          Caption = 'Teeth number on the dental chart'
          TabOrder = 7
        end
      end
      object GBIU: TGroupBox
        Left = 16
        Top = 217
        Width = 245
        Height = 120
        Caption = '  Internet upgrade reminder  '
        TabOrder = 5
        DesignSize = (
          245
          120)
        object RBIUInterval: TRadioGroup
          Left = 10
          Top = 21
          Width = 225
          Height = 60
          Anchors = [akLeft, akTop, akRight, akBottom]
          Columns = 3
          ItemIndex = 5
          Items.Strings = (
            'Never'
            'Everyday'
            '7 days'
            '14 days'
            '30 days'
            '90 days')
          TabOrder = 0
        end
        object CmBIUCMDLType: TComboBox
          Left = 80
          Top = 91
          Width = 82
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 1
          Text = 'Production'
          Items.Strings = (
            'Production'
            'Pilot')
        end
      end
      object BtEmailSettings: TButton
        Left = 16
        Top = 346
        Width = 105
        Height = 25
        Caption = 'E-mail settings'
        TabOrder = 6
        OnClick = BtEmailSettingsClick
      end
      object GBImageUpdate: TGroupBox
        Left = 493
        Top = 312
        Width = 198
        Height = 73
        Caption = '  Image changes update  '
        TabOrder = 7
        DesignSize = (
          198
          73)
        object LbIUDelayCapt: TLabel
          Left = 88
          Top = 48
          Width = 38
          Height = 13
          Caption = 'Delay, s'
        end
        object ChBIUMouseStop: TCheckBox
          Left = 16
          Top = 21
          Width = 177
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Update on the mouse stop'
          TabOrder = 0
          OnClick = ChBIUMouseStopClick
        end
        object CmBIUMouseDelay: TComboBox
          Left = 16
          Top = 43
          Width = 62
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 1
          Text = '0.2'
          OnClick = ChBIUMouseStopClick
          Items.Strings = (
            '0.2'
            '0.4'
            '0.6'
            '0.8'
            '1.0')
        end
      end
      object CmBUseToolbarType: TComboBox
        Left = 272
        Top = 317
        Width = 209
        Height = 21
        ItemHeight = 13
        TabOrder = 8
        Text = 'Use Toolbar Provider Settings'
        Items.Strings = (
          'Use Toolbar Provider/PC Settings'
          'Use Toolbar Provider Settings'
          'Use Toolbar Location Settings'
          'Use Toolbar Global Settings')
      end
    end
    object TSColorizeIsodensity: TTabSheet
      Caption = 'Tools'
      ImageIndex = 1
      object GBColorise: TGroupBox
        Left = 8
        Top = 16
        Width = 297
        Height = 65
        Caption = '   Colourise  '
        TabOrder = 0
        DesignSize = (
          297
          65)
        object CmBPalsList: TComboBox
          Left = 10
          Top = 24
          Width = 276
          Height = 22
          Style = csOwnerDrawVariable
          Anchors = [akLeft, akTop, akRight]
          ItemHeight = 16
          TabOrder = 0
          OnChange = CmBPalsListChange
          OnDrawItem = CmBPalsListDrawItem
          Items.Strings = (
            'Sepia'
            'Hot'
            'Black-Blue-Cyan-White'
            'Blue-Yellow-Green'
            'Blue-Magenta-Red')
        end
      end
      object ChBShowEmbossDetails: TCheckBox
        Left = 333
        Top = 32
        Width = 195
        Height = 17
        Caption = 'Show Emboss Dialog  '
        TabOrder = 1
        OnClick = ChBShowEmbossDetailsClick
      end
      object GBFilters: TGroupBox
        Left = 8
        Top = 90
        Width = 441
        Height = 65
        Caption = '  Filter setup  '
        TabOrder = 2
        object LbFilter: TLabel
          Left = 10
          Top = 16
          Width = 22
          Height = 13
          Caption = 'Filter'
        end
        object LbFHotKey: TLabel
          Left = 95
          Top = 16
          Width = 38
          Height = 13
          Caption = 'Hot Key'
        end
        object LbFUDCaption: TLabel
          Left = 208
          Top = 16
          Width = 36
          Height = 13
          Caption = 'Caption'
        end
        object CmBFilters: TComboBox
          Left = 10
          Top = 32
          Width = 77
          Height = 21
          Style = csDropDownList
          DropDownCount = 10
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 0
          Text = 'Filter A'
          OnChange = CmBFiltersChange
          Items.Strings = (
            'Filter A'
            'Filter B'
            'Filter C'
            'Filter D'
            'Filter E'
            'Filter F'
            'Filter 1'
            'Filter 2'
            'Filter 3'
            'Filter 4')
        end
        object CmBShortCuts: TComboBox
          Left = 94
          Top = 32
          Width = 105
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 1
          OnChange = CmBShortCutsChange
        end
        object BtFilterSetup: TButton
          Left = 352
          Top = 30
          Width = 76
          Height = 23
          Caption = 'Setup'
          TabOrder = 2
          OnClick = BtFilterSetupClick
        end
        object EdFUDCaption: TEdit
          Left = 208
          Top = 31
          Width = 129
          Height = 21
          MaxLength = 20
          TabOrder = 3
          OnChange = EdFUDCaptionChange
        end
      end
      object GBCTA: TGroupBox
        Left = 8
        Top = 170
        Width = 441
        Height = 65
        Caption = '  Customizable text annotations setup  '
        TabOrder = 3
        object LbCTA: TLabel
          Left = 10
          Top = 16
          Width = 79
          Height = 13
          Caption = 'Text annotations'
        end
        object LbCTAHotKey: TLabel
          Left = 95
          Top = 16
          Width = 38
          Height = 13
          Caption = 'Hot Key'
        end
        object LbCTACaption: TLabel
          Left = 208
          Top = 16
          Width = 36
          Height = 13
          Caption = 'Caption'
        end
        object CmBCTA: TComboBox
          Left = 10
          Top = 32
          Width = 77
          Height = 21
          Style = csDropDownList
          DropDownCount = 10
          ItemHeight = 13
          ItemIndex = 0
          TabOrder = 0
          Text = 'Text 1'
          OnChange = CmBCTAChange
          Items.Strings = (
            'Text 1'
            'Text 2'
            'Text 3'
            'Text 4')
        end
        object CmBShortCuts1: TComboBox
          Left = 94
          Top = 32
          Width = 105
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 1
          OnChange = CmBShortCuts1Change
        end
        object BtCTASetup: TButton
          Left = 352
          Top = 30
          Width = 76
          Height = 23
          Caption = 'Setup'
          TabOrder = 2
          OnClick = BtCTASetupClick
        end
        object EdCTACaption: TEdit
          Left = 208
          Top = 31
          Width = 129
          Height = 21
          MaxLength = 20
          TabOrder = 3
          OnChange = EdCTACaptionChange
        end
      end
    end
  end
  object BtCancel: TButton
    Left = 642
    Top = 441
    Width = 60
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object BtOK: TButton
    Left = 570
    Top = 441
    Width = 60
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 2
  end
  object ActionList1: TActionList
    Left = 24
    Top = 400
    object AddMType: TAction
      Caption = '&Add'
      Hint = 'Add new Media Category'
      OnExecute = AddMTypeExecute
    end
    object DelMType: TAction
      Caption = '&Delete'
      Hint = 'Delete existing Media Category'
      OnExecute = DelMTypeExecute
    end
  end
end
