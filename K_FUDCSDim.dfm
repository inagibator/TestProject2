inherited K_FormUDCSDim: TK_FormUDCSDim
  Left = 245
  Top = 314
  Width = 653
  Height = 556
  Caption = #1056#1077#1076#1072#1082#1090#1086#1088' '#1085#1072#1073#1086#1088#1072' '#1101#1083#1077#1084#1077#1085#1090#1086#1074' '#1080#1079#1084#1077#1088#1077#1085#1080#1103
  Constraints.MaxWidth = 653
  Constraints.MinWidth = 653
  Menu = MainMenu1
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    645
    502)
  PixelsPerInch = 96
  TextHeight = 13
  object LbID: TLabel [0]
    Left = 14
    Top = 481
    Width = 17
    Height = 13
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'ID :'
  end
  object Label1: TLabel [1]
    Left = 32
    Top = 0
    Width = 155
    Height = 13
    Caption = #1053#1072#1073#1086#1088' '#1101#1083#1077#1084#1077#1085#1090#1086#1074' '#1080#1079#1084#1077#1088#1077#1085#1080#1103' :'
  end
  object Label2: TLabel [2]
    Left = 301
    Top = 0
    Width = 25
    Height = 13
    Caption = #1058#1080#1087' :'
  end
  object Label3: TLabel [3]
    Left = 504
    Top = 0
    Width = 64
    Height = 13
    Caption = #1048#1079#1084#1077#1088#1077#1085#1080#1077' :'
  end
  inherited BFMinBRPanel: TPanel
    Left = 633
    Top = 489
    TabOrder = 10
  end
  object BtCancel: TButton
    Left = 519
    Top = 477
    Width = 57
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = #1054#1090#1082#1072#1079
    ModalResult = 2
    TabOrder = 0
    OnClick = BtCancelClick
  end
  object BtOK: TButton
    Left = 586
    Top = 477
    Width = 57
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = #1054#1050
    ModalResult = 1
    TabOrder = 1
    OnClick = BtOKClick
  end
  object Button1: TButton
    Left = 392
    Top = 477
    Width = 71
    Height = 21
    Action = ApplyCurCSDim
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  object EdID: TEdit
    Left = 31
    Top = 477
    Width = 210
    Height = 21
    Anchors = [akLeft, akBottom]
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 3
  end
  object Panel1: TPanel
    Left = 0
    Top = 39
    Width = 646
    Height = 433
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Panel1'
    TabOrder = 4
    inline FrameCDSetInds: TK_FrameCSDim1
      Left = 1
      Top = 1
      Width = 644
      Height = 431
      Align = alClient
      TabOrder = 0
      inherited K_FrameRAEditS: TK_FrameRAEdit
        Width = 644
        Height = 431
        inherited SGrid: TStringGrid
          Width = 644
          Height = 431
        end
      end
    end
    inline FrameCSDim: TK_FrameCSDim2
      Left = 1
      Top = 1
      Width = 644
      Height = 431
      Align = alClient
      Constraints.MaxWidth = 644
      Constraints.MinWidth = 644
      TabOrder = 1
      inherited K_FrameRAEditS: TK_FrameRAEdit
        Height = 431
        inherited SGrid: TStringGrid
          Height = 431
        end
      end
      inherited BBtnDel: TButton
        Action = FrameCSDim.K_FrameRAEditSS.DelRow
      end
      inherited K_FrameRAEditSS: TK_FrameRAEdit
        Height = 431
        inherited SGrid: TStringGrid
          Height = 431
        end
      end
    end
  end
  inline CSDFrameUDList: TK_FrameUDList
    Left = 4
    Top = 13
    Width = 219
    Height = 25
    TabOrder = 5
    inherited UDIcon: TImage
      Width = 19
      Height = 19
      Visible = True
    end
  end
  object CmBIndsType: TComboBox
    Left = 241
    Top = 15
    Width = 143
    Height = 21
    ItemHeight = 13
    TabOrder = 6
    OnChange = CmBIndsTypeChange
  end
  object EdCDim: TEdit
    Left = 408
    Top = 15
    Width = 229
    Height = 21
    Color = clBtnFace
    ReadOnly = True
    TabOrder = 7
  end
  object BBDelAll: TButton
    Left = 325
    Top = 475
    Width = 25
    Height = 25
    Action = FrameCDSetInds.DelAll
    Anchors = [akLeft, akBottom]
    Caption = 'X<<'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 8
  end
  object BBAddAll: TButton
    Left = 293
    Top = 475
    Width = 25
    Height = 25
    Action = FrameCDSetInds.AddAll
    Anchors = [akLeft, akBottom]
    Caption = '>>'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 9
  end
  object ActionList1: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 608
    object CreateCSDim: TAction
      Caption = #1057#1086#1079#1076#1072#1090#1100' ...'
      Hint = #1057#1086#1079#1076#1072#1090#1100' '#1086#1073#1098#1077#1082#1090
      ImageIndex = 0
      OnExecute = CreateCSDimExecute
    end
    object ApplyCurCSDim: TAction
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      OnExecute = ApplyCurCSDimExecute
    end
    object CloseAction: TAction
      Caption = #1042#1099#1093#1086#1076
      OnExecute = CloseActionExecute
    end
    object RenameCSDim: TAction
      Caption = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100' ...'
      Hint = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100' '#1086#1073#1098#1077#1082#1090
      OnExecute = RenameCSDimExecute
    end
  end
  object MainMenu1: TMainMenu
    Images = N_ButtonsForm.ButtonsList
    Left = 576
    object N1: TMenuItem
      Caption = #1054#1073#1098#1077#1082#1090
      object N2: TMenuItem
        Action = CreateCSDim
        Caption = #1057#1086#1079#1076#1072#1090#1100' '#1085#1072#1073#1086#1088' '#1101#1083#1077#1084#1077#1085#1090#1086#1074' '#1080#1079#1084#1077#1088#1077#1085#1080#1103' ...'
        Hint = #1057#1086#1079#1076#1072#1090#1100' '#1085#1072#1073#1086#1088' '#1101#1083#1077#1084#1077#1085#1090#1086#1074' '#1080#1079#1084#1077#1088#1077#1085#1080#1103' ...'
      end
      object N4: TMenuItem
        Action = CSDFrameUDList.SelectUDObj
        Caption = #1042#1099#1073#1088#1072#1090#1100' '#1085#1072#1073#1086#1088' '#1101#1083#1077#1084#1077#1085#1090#1086#1074' '#1080#1079#1084#1077#1088#1077#1085#1080#1103' ...'
        Hint = #1042#1099#1073#1088#1072#1090#1100' '#1085#1072#1073#1086#1088' '#1101#1083#1077#1084#1077#1085#1090#1086#1074' '#1080#1079#1084#1077#1088#1077#1085#1080#1103' ...'
      end
      object N3: TMenuItem
        Action = RenameCSDim
        Caption = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100' '#1085#1072#1073#1086#1088' '#1101#1083#1077#1084#1077#1085#1090#1086#1074' '#1080#1079#1084#1077#1088#1077#1085#1080#1103' ...'
        Hint = #1055#1077#1088#1077#1080#1084#1077#1085#1086#1074#1072#1090#1100' '#1085#1072#1073#1086#1088' '#1101#1083#1077#1084#1077#1085#1090#1086#1074' '#1080#1079#1084#1077#1088#1077#1085#1080#1103' ...'
      end
      object N5: TMenuItem
        Action = CloseAction
      end
    end
    object N6: TMenuItem
      Caption = #1055#1088#1072#1074#1082#1072
    end
  end
end
