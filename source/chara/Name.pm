#===================================================================
#        PC名、愛称取得パッケージ
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
package Name;

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

    $self->{CommonDatas}{NickName} = {};
    $self->{NickName} = {};
    
    #初期化
    $self->{Datas}{Data}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "e_no",
                "name",
                "nickname",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/name_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜結果番号,ターン別参加者一覧ノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $page_no = shift;
    my $nodes = shift;

    $self->GetNameData($nodes);
    
    return;
}
#-----------------------------------#
#    愛称データ取得
#------------------------------------
#    引数｜ターン別参加者一覧ノード
#-----------------------------------#
sub GetNameData{
    my $self  = shift;
    my $turn_table_nodes = shift;

    if (!scalar(@$turn_table_nodes)) {return;}

    my $a_nodes = &GetNode::GetNode_Tag("a", \$$turn_table_nodes[0]);
    foreach my $a_node (@$a_nodes) {
        if ($a_node->attr("href") =~ /id=(\d+)/) {
            $self->{NickName}{$1} = $a_node->as_text;
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
    
    foreach my $e_no (sort{$a <=> $b} keys(%{$self->{NickName}})) {
        $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $e_no, "", $self->{NickName}{$e_no})));
    }

    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
