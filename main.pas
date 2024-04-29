
Uses GraphABC;

Const types =   3;
    //число типов рыб минус 1
    rmax =   4;
    //радиус всех рыб
    CanEat =   rmax;
    //максимальное расстояние при поедании
    eps =   0.00001;
    //необходимо при операциях с данными real
    epsustupi =   0.1;
    //насколько значима иерархия среди хищников
    strahkraj =   3;
    //во сколько раз жертвы боятся края меньше, чем хищников
    ustupi =   CanEat*10;
    //насколько значима иерархия среди хищников
    BkColor =   clBlack;
    //Фон
    Height =   600;
    //Высота графического окна
    Width =   780;
    //Ширина графического окна
    xmin =   10;
    //
    ymin =   10;
    //Минимальные и максимальные значения координат,
    xmax =   Width - 100;
    //которые могут принимать рыбы
    ymax =   Height - 140;
    //

Type 
    fishtype =   Class //Описание одной стаи
        c :   color;
        Public 
            CanRazm, MaxKol, Kol, MaxLife, MinFood:   integer;
            //цвет, размножение, макс. кол-во, текущее кол-во, макс. жизнь,
            //сколько хищнику нужно есть для размножения
            Speed, See:   real;
            //Нормальная скорость и зрение в пикселях
            constructor create(ac:color; aCanRazm, aMaxKol, aMaxLife, aMinFood:integer; aSpeed, aSee: real);
            Begin
                c := ac;
                CanRazm := aCanRazm;
                MaxKol := aMaxKol;
                Kol := 1;
                MaxLife := aMaxLife;
                MinFood := aMinFood;
                Speed := aSpeed;
                See := aSee
            End;
            Procedure ShowKol(y: integer);
            //отобразить текущее кол-во

            Var s:   string;
            Begin
                SetFontColor(c);
                TextOut(xmax + 20, y, ' ');
                s := IntToStr(kol);
                TextOut(xmax + 20, y, s);
            End;
    End;

Var opisanie:   array[0..types] Of fishtype;
    //данные для всех стай

Type 
    fish =   Class
        x, y, r, dx0, dy0:   real;
        //текущие координаты, радиус и предыдущий шаг
        tip, life, razm, status, food:   integer;
        //razm - время с момента последнего размножения,
        //status - состояние - спокойное или возбуждённое
        next, prev:   fish;
        //двусвязный циклический список
        constructor Create(ax, ay, ar: real; atip: integer; aprev, anext: fish);
        Begin
            x := ax;
            y := ay;
            r := ar;
            tip := atip;
            prev := aprev;
            next := anext;
            life := 0;
            razm := 0;
            dx0 := random;
            dy0 := random;
            status := 1;
            food := 0;
        End;
        Procedure show;
        Begin
            SetPenColor(opisanie[tip].c);
            circle(round(x), round(y), round(r))
        End;
        Procedure hide;
        Begin
            SetPenColor(BkColor);
            circle(round(x), round(y), round(r))
        End;
        Procedure Destroy;
        Begin
            hide;
            opisanie[tip].kol := opisanie[tip].kol - 1;
            opisanie[tip].ShowKol(tip*40 + 20);
        End;
        Procedure moveto(dx, dy: real);
        Begin
            hide;
            x := x + dx;
            y := y + dy;
            If x > xmax Then x := xmax;
            If x < xmin Then x := xmin;
            If y > ymax Then y := ymax;
            If y < ymin Then y := ymin;
            show
        End;

        Procedure MakeDeti(Var mama, StartAkula, KonAkula, StartKilka, KonKilka : fish);
        //произвести потомство

        Var d:   fish;
        Begin
            razm := 0;
            food := 0;
            d := fish.create(x, y, r, tip, mama, next);
            next.prev := d;
            next := d;
            If mama = KonAkula Then KonAkula := d;
            If mama = KonKilka Then KonKilka := d;
            opisanie[tip].kol := opisanie[tip].kol + 1;
            opisanie[tip].ShowKol(tip*40 + 20);
        End;

        Procedure step(Var ribka, StartAkula, KonAkula, StartKilka, KonKilka : fish);
        //Здесь алгоритмы для рыб

        Var 
            dx, dy, d, dx2, dy2, dmin:   real;
            t, trup, found:   fish;
            FoundOhot:   boolean;
        Begin
            status := 1;
            //Нормальное состояние
            dx := 0;
            dy := 0;
            If tip > 0 Then
                Begin
                    //Начало алгоритма для жертв
                    t := StartAkula;
                    If t<>Nil Then
                        Repeat
                            //Ищем всех хищников в поле видимости
                            d := sqrt((x - t.x)*(x - t.x) + (y - t.y)*(y - t.y));
                            If d < opisanie[tip].See Then
                                Begin
                                    If d < eps Then d := eps;
                                    dx2 := (x - t.x)/(d*d);
                                    dy2 := (y - t.y)/(d*d);
                                    dx := dx + dx2;
                                    dy := dy + dy2;
                                    status := 2;
                                    //Возбуждённое состояние
                                End;
                            t := t.next
                        Until t = KonAkula.next;
                    //И обратим внимание на края:
                    If x - xmin < opisanie[tip].See Then dx := dx + 1/((x - xmin + eps)*strahkraj);
                    If xmax - x < opisanie[tip].See Then dx := dx + 1/((x - xmax - eps)*strahkraj);
                    If y - ymin < opisanie[tip].See Then dy := dy + 1/((y - ymin + eps)*strahkraj);
                    If ymax - y < opisanie[tip].See Then dy := dy + 1/((y - ymax - eps)*strahkraj);
                    d := sqrt(dx*dx + dy*dy);
                    If d < eps Then
                        Begin
                            dx := 2*status*random()*opisanie[tip].Speed - status*opisanie[tip].Speed;
                            dy := 2*status*random()*opisanie[tip].Speed - status*opisanie[tip].Speed
                        End
                    Else
                        Begin
                            dx := status*opisanie[tip].Speed*dx/d;
                            dy := status*opisanie[tip].Speed*dy/d
                        End
                End
            Else {tip = 0}
                Begin
                    //Начало алгоритма для хищников
                    dmin := 11000;
                    t := StartAkula;
                    While t<>ribka Do
                        //Проверяем всех выше по иерархии
                        Begin

                            d := sqrt((x - t.x)*(x - t.x) + (y - t.y)*(y - t.y));
                            If (d < dmin) And (abs(dx0 - t.dx0) < epsustupi) And
                               (abs(dy0 - t.dy0) < epsustupi) Then dmin := d;

                            t := t.next
                        End;
                    FoundOhot := dmin < ustupi;
                    dmin := 11000;
                    found := Nil;
                    t := StartKilka;
                    If (t<>Nil) And (life > 100) And Not FoundOhot Then
                        Repeat

                            d := sqrt((x - t.x)*(x - t.x) + (y - t.y)*(y - t.y));
                            If d < dmin Then
                                Begin
                                    dmin := d;
                                    found := t //found - ближайшая жертва
                                End;
                            t := t.next
                        Until t = KonKilka.next;
                    If (found <> Nil) And (dmin < opisanie[tip].See) Then
                        Begin
                            status := 2;
                            //Возбуждённое состояние
                            dx := found.x - x;
                            dy := found.y - y;
                            If dmin < CanEat + status*opisanie[tip].Speed Then
                                Begin
                                    //Поедание
                                    found.next.prev := found.prev;
                                    found.prev.next := found.next;
                                    If (found = StartKilka) And (found = KonKilka) Then
                                        Begin
                                            //StartKilka:= nil;
                                            //KonKilka:= nil
                                        End;
                                    If found = StartKilka Then
                                        StartKilka := StartKilka.next;
                                    If found = KonKilka Then
                                        KonKilka := KonKilka.prev;
                                    found.destroy;
                                    found := Nil;
                                    food := food + 1
                                End
                        End
                    Else
                        If (x <= xmin) Or (x >= xmax) Or (y <= ymin) Or (y >= ymax) Then
                            Begin
                                dx := 2*status*random()*opisanie[tip].Speed - status*opisanie[tip].Speed;
                                dy := 2*status*random()*opisanie[tip].Speed - status*opisanie[tip].Speed
                            End
                    Else
                        Begin
                            dx := dx0;
                            dy := dy0 //Повтор предыдущего шага - патрулирование
                        End;
                    d := sqrt(dx*dx + dy*dy);
                    If d > eps Then
                        Begin
                            dx := status*opisanie[tip].Speed*dx/d;
                            dy := status*opisanie[tip].Speed*dy/d;
                        End
                End;
            //Начало алгоритма для всех рыб
            moveto(dx, dy);
            dx0 := dx;
            dy0 := dy;
            life := life + 1;
            razm := razm + 1;
            If opisanie[tip].Kol >= opisanie[tip].MaxKol Then Razm := 0;
            If (razm > opisanie[tip].CanRazm) And (food >= opisanie[tip].minfood) Then
                MakeDeti(ribka, StartAkula, KonAkula, StartKilka, KonKilka);
            If life > opisanie[tip].MaxLife Then //Смерть от старости
                Begin
                    trup := ribka;
                    ribka := ribka.prev;
                    trup.next.prev := trup.prev;
                    trup.prev.next := trup.next;
                    If trup = StartKilka Then
                        StartKilka := StartKilka.next;
                    If trup = KonKilka Then
                        KonKilka := KonKilka.prev;
                    If trup = StartAkula Then
                        StartAkula := StartAkula.next;
                    If trup = KonAkula Then
                        KonAkula := KonAkula.prev;
                    If trup = trup.next Then ribka := Nil;
                    If trup <> Nil Then
                        trup.destroy;
                    trup := Nil;
                End
        End;

    End;

Function getAllCount:   integer;

Var i,c:   integer;
Begin
    c := 0;
    For i:=0 To types Do
        c := c+opisanie[i].Kol;
    getAllCount := c;
End;

Var i:   integer;
    p, q, StartAkula, StartKilka, KonAkula, KonKilka, tek:   fish;

Begin
    SetSmoothing(False);
    SetWindowSize(Width, Height);
    SetWindowLeft(200);
    SetWindowTop(50);
    SetWindowCaption('Битва за жизнь');
    SetFontSize(7);
    SetFontName('Arial');
    SetBrushColor(BkColor);
    FillRectangle(0, 0, Width, Height);
    SetFontColor(clWhite);
    TextOut(10, ymax + 20, 'Автор программы - Иванов С.О. e-mail: ssyy@yandex.ru');
    TextOut(10, ymax + 20+1*18,
'Программа моделирует поведение нескольких стай рыб. Справа - количества рыб в текущий'
    );
    TextOut(10, ymax + 20+2*18,
'момент времени. Изменяя параметры в коде программы, можно влиять на ход битвы.'
    );
    TextOut(10, ymax + 20+3*18,
'По умолчанию: красные - хищники, поедают любых рыб из других стай, не плодятся,'
    );
    TextOut(10, ymax + 20+4*18,
'пока не поели; синие - жертвы, самые медленные, но быстрее всех плодятся; зелёные - жертвы,'
    );
    TextOut(10, ymax + 20+5*18,
'быстрее синих, но плодятся медленнее; желтые - самые быстрые среди жертв, но желтых мало.'
    );
    SetFontSize(12);
    StartAkula := Nil;
    StartKilka := Nil;
    KonAkula := Nil;
    KonKilka := Nil;

    //c - цвет.

//CanRazm - минимальное количество ходов отдельно взятой рыбы между двумя
    // её последовательными размножениями.
    //MaxKol - максимально допустимое количество рыб данного вида.
    //Kol - количество рыб данного вида в текущий момент времени.
    //MaxLife - максимальная продолжительность жизни.

// После того, как рыба сделает больше шагов, чем это число, она умирает.

//MinFood - минимальное количество съеденных жертв, необходимое для размножения
    // (только для хищников; для жертв это количество принято за -1).

//Speed - нормальная скорость. Максимальная скорость рыбы в 2 раза больше этого числа.
    //See - радиус обзора - как далеко видит рыба.

    //c, CanRazm, MaxKol, MaxLife, MinFood, Speed, See
    opisanie[3] := fishtype.create(clYellow, 300, 15, 1500, -1, 0.99, 50);
    opisanie[2] := fishtype.create(clGreen, 150, 50, 1500, -1, 0.9, 50);
    opisanie[1] := fishtype.create(clBlue, 30, 50, 500, -1, 0.7, 35);
    opisanie[0] := fishtype.create(clRed, 1000, 40, 5000, 1, 1, 500);
    SetPenColor(clWhite);
    rectangle(round(xmin - rmax - 1), round(ymin - rmax - 1),
    round(xmax + rmax + 1), round(ymax + rmax + 1));
    //Теперь нужно построить первоначальный список
    q := fish.create(xmin + 10, ymax - 10, rmax, 0, Nil, Nil);
    p := fish.create(xmin + 10, ymin + 10, rmax, 1, q, q);
    q.next := p;
    q.prev := p;
    StartAkula := q;
    KonAkula := q;
    StartKilka := p;
    KonKilka := p;
    p := fish.create(xmax - 10, ymin + 10, rmax, 2, KonKilka, StartAkula);
    StartAkula.prev := p;
    KonKilka.next := p;
    KonKilka := p;
    p := fish.create(xmax - 10, ymax - 10, rmax, 3, KonKilka, StartAkula);
    StartAkula.prev := p;
    KonKilka.next := p;
    KonKilka := p;
    For i:= 0 To types Do
        opisanie[i].ShowKol(i*40 + 20);
    //И все ходят по очереди, пока хоть кто-то жив.
    tek := StartKilka;
    //i:=0;c:=getallcount;LockDrawing;
    Repeat
        tek := tek.next;
        tek.step(tek, StartAkula, KonAkula, StartKilka, KonKilka);
{i:=i+1;
if i>=c then begin
i:=0;c:=getallcount;
Redraw;
end;}
    Until (tek = Nil);

End.
