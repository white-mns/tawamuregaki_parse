#===================================================================
#        パーティ情報取得パッケージ
#-------------------------------------------------------------------
#            (C) 2018 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#   
use strict;
use warnings;
require "./source/lib/Store_Data.pm";
require "./source/lib/Store_HashData.pm";
use ConstData;        #定数呼び出し
use source::lib::GetNode;

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package Party;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;
  
  bless {
        Datas => {},
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init(){
    my $self = shift;
    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas}) = @_;

    $self->{CommonDatas}{NickParty} = {};
    $self->{NickParty} = {};
    
    #初期化
    $self->{Datas}{Data}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "battle_no",
                "e_no",
                "party_order",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/battle/party_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜結果番号,ターン別参加者一覧ノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $battle_no = shift;
    my $nodes = shift;
    
    $self->{BattleNo} = $battle_no;

    $self->GetPartyData($nodes);
    
    return;
}

#-----------------------------------#
#    メンバーデータ取得
#------------------------------------
#    引数｜ターン別参加者一覧ノード
#-----------------------------------#
sub GetPartyData{
    my $self  = shift;
    my $turn_table_nodes = shift;

    if (!scalar(@$turn_table_nodes)) {return;}

    my $party_order = 0;

    my $a_nodes = &GetNode::GetNode_Tag("a", \$$turn_table_nodes[0]);

    foreach my $a_node (@$a_nodes) {
        if ($a_node->attr("href") =~ /id=(\d+)/) {
            my $e_no = $1;

            $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $self->{BattleNo}, $e_no, $party_order) ));

            $party_order += 1;
        }

    }

    return;
}

#-----------------------------------#
#    出力
#------------------------------------
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output(){
    my $self = shift;
    
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
