inherited K_FormCSDim: TK_FormCSDim
  Left = 134
  Top = 238
  Width = 653
  Height = 557
  Caption = #1056#1077#1076#1072#1082#1090#1086#1088' '#1085#1072#1073#1086#1088#1072' '#1101#1083#1077#1084#1077#1085#1090#1086#1074' '#1080#1079#1084#1077#1088#1077#1085#1080#1103
  Constraints.MaxWidth = 671
  Constraints.MinWidth = 653
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    645
    523)
  PixelsPerInch = 96
  TextHeight = 13
  object LbIndsType: TLabel [0]
    Left = 1
    Top = 501
    Width = 25
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = #1058#1080#1087' :'
  end
  inherited BFMinBRPanel: TPanel
    Left = 633
    Top = 511
    TabOrder = 8
  end
  object BtCancel: TButton
    Left = 519
    Top = 498
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
    Top = 498
    Width = 57
    Height = 21
    Anchors = [akRight, akBottom]
    Caption = #1054#1050
    ModalResult = 1
    TabOrder = 1
    OnClick = BtOKClick
  end
  object Button1: TButton
    Left = 413
    Top = 498
    Width = 71
    Height = 21
    Action = ApplyCurCSDim
    Anchors = [akRight, akBottom]
    TabOrder = 2
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 645
    Height = 490
    Align = alTop
    Anchors = [akLeft, akTop, akRight, akBottom]
    Caption = 'Panel1'
    TabOrder = 3
    DesignSize = (
      645
      490)
    object Label2: TLabel
      Left = 2
      Top = 5
      Width = 61
      Height = 13
      Caption = #1048#1079#1084#1077#1088#1077#1085#1080#1077':'
    end
    inline FrameCDSetInds: TK_FrameCSDim1
      Left = 1
      Top = 24
      Width = 644
      Height = 466
      Anchors = [akLeft, akTop, akRight, akBottom]
      Constraints.MaxWidth = 644
      Constraints.MinWidth = 644
      TabOrder = 0
      inherited K_FrameRAEditS: TK_FrameRAEdit
        Width = 644
        Height = 466
        inherited SGrid: TStringGrid
          Width = 644
          Height = 466
        end
      end
    end
    object EdCDim: TEdit
      Left = 72
      Top = 1
      Width = 569
      Height = 21
      Color = clBtnFace
      ReadOnly = True
      TabOrder = 2
    end
    inline FrameCSDim: TK_FrameCSDim2
      Left = 1
      Top = 24
      Width = 644
      Height = 466
      Anchors = [akLeft, akTop, akRight, akBottom]
      Constraints.MaxWidth = 644
      Constraints.MinWidth = 644
      TabOrder = 1
      inherited K_FrameRAEditS: TK_FrameRAEdit
        Height = 466
        inherited SGrid: TStringGrid
          Height = 466
        end
      end
      inherited BBtnDel: TButton
        Action = FrameCSDim.K_FrameRAEditSS.DelRow
      end
      inherited K_FrameRAEditSS: TK_FrameRAEdit
        Height = 466
        inherited SGrid: TStringGrid
          Height = 466
        end
      end
    end
  end
  object CmBIndsType: TComboBox
    Left = 30
    Top = 498
    Width = 143
    Height = 21
    Anchors = [akLeft, akBottom]
    ItemHeight = 13
    TabOrder = 4
    OnChange = CmBIndsTypeChange
  end
  object BtCreate: TButton
    Left = 210
    Top = 498
    Width = 75
    Height = 21
    Action = CreateCSDim
    Anchors = [akLeft, akBottom]
    Caption = #1057#1086#1079#1076#1072#1090#1100' ...'
    TabOrder = 5
  end
  object BBAddAll: TButton
    Left = 320
    Top = 495
    Width = 25
    Height = 25
    Action = FrameCDSetInds.AddAll
    Anchors = [akLeft, akBottom]
    Caption = '>>'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
  end
  object BBDelAll: TButton
    Left = 352
    Top = 495
    Width = 25
    Height = 25
    Action = FrameCDSetInds.DelAll
    Anchors = [akLeft, akBottom]
    Caption = 'X<<'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 7
  end
  object ActionList1: TActionList
    Images = N_ButtonsForm.ButtonsList
    Left = 96
    Top = 496
    object ApplyCurCSDim: TAction
      Caption = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      Hint = #1055#1088#1080#1084#1077#1085#1080#1090#1100
      OnExecute = ApplyCurCSDimExecute
    end
    object CloseAction: TAction
      Caption = #1042#1099#1093#1086#1076
      OnExecute = CloseActionExecute
    end
    object CreateCSDim: TAction
      Caption = #1057#1086#1079#1076#1072#1090#1100' '#1086#1073#1098#1077#1082#1090' ...'
      OnExecute = CreateCSDimExecute
    end
  end
end
