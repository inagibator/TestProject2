inherited K_FormCMFixStudyDataWarn: TK_FormCMFixStudyDataWarn
  Left = 287
  Top = 380
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Advanced settings'
  ClientHeight = 155
  ClientWidth = 494
  PixelsPerInch = 96
  TextHeight = 13
  object Image: TImage [0]
    Left = 8
    Top = 8
    Width = 32
    Height = 32
  end
  inherited BFMinBRPanel: TPanel
    Left = 484
    Top = 145
    TabOrder = 2
  end
  object BtCancel: TButton
    Left = 263
    Top = 119
    Width = 98
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&Postpone'
    ModalResult = 2
    TabOrder = 0
  end
  object BtOK: TButton
    Left = 182
    Top = 119
    Width = 65
    Height = 23
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    ModalResult = 1
    TabOrder = 1
  end
  object Memo1: TMemo
    Left = 56
    Top = 8
    Width = 425
    Height = 97
    Lines.Strings = (
      
        'The system has detected your study data is not consistent with t' +
        'he current build of the '
      
        'Media Suite. You have 2 options to fix this problem automaticall' +
        'y:'
      
        '1.'#9'Click '#8220'OK'#8221' to let the system to convert your study data right' +
        ' now.'
      
        '2.'#9'Click '#8220'Postpone'#8221' to start this procedure later at your conven' +
        'ient time by going '
      
        'to the Go to menu in the Media Suite and selecting '#8220'Fix the stud' +
        'y data'#8221' in the options '
      'available.'
      '')
    TabOrder = 3
  end
end
