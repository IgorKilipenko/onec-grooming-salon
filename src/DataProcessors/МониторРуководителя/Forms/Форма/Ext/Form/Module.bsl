﻿#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура ПриОткрытии(_)
    инициализацияСтраницыНовостей();
    заполнитьПериодОбработки();
    заполнитьДанные();
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийФормы

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ОбновитьМониторРуководителя(_)
    заполнитьДанные();
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьЛентуНовостей(_)
    ЭтотОбъект.Новости = получитьНовостиНаСервере(
            ЭтотОбъект.НовостиСтрокаПоиска,
            ЭтотОбъект.НовостиДатаЗагрузки,
            ЭтотОбъект.НовостиЯзыкПоиска,
            ЭтотОбъект.НовостиКоличество);

    курсыВалютЦБ = получитьКурсыВалютНаСервере(ЭтотОбъект.НовостиДатаЗагрузки);
    ЭтотОбъект.КурсДоллара = курсыВалютЦБ.USD;
    ЭтотОбъект.КурсЕвро = курсыВалютЦБ.EURO;
    ЭтотОбъект.КурсТенге = курсыВалютЦБ.KZT;

КонецПроцедуры

#КонецОбласти // ОбработчикиКомандФормы

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура МесяцСтрокойНажатие(_, стандартнаяОбработка)
    стандартнаяОбработка = Ложь;
    выбратьПериодОбработки(Истина);
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытийЭлементовШапкиФормы

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура заполнитьДанные()
    датаНачала = ЭтотОбъект.ПериодОбработки;
    датаОкончания = КонецМесяца(ЭтотОбъект.ПериодОбработки);

    заполнитьЧисловыеПоказатели(датаНачала, датаОкончания);

    заполнитьДиаграммуВыручки();
    заполнитьКруговыеДиаграммы();
КонецПроцедуры

&НаКлиенте
Асинх Функция выбратьПериодОбработки(Знач обновитьДанные = Ложь)
    подсказка = "Введите период получения данных";
    частьДаты = ЧастиДаты.Дата;
    результатДата = Ждать ВвестиДатуАсинх(ЭтотОбъект.ПериодОбработки, подсказка, частьДаты);
    Если результатДата <> Неопределено Тогда
        ЭтотОбъект.ПериодОбработки = НачалоМесяца(результатДата);
        ЭтотОбъект.МесяцСтрокой = Формат(ЭтотОбъект.ПериодОбработки, получитьФорматПериода());
        заполнитьДанные();
        Возврат Истина;
    КонецЕсли;

    Возврат Ложь;
КонецФункции

&НаКлиенте
Процедура заполнитьПериодОбработки()
    ЭтотОбъект.ПериодОбработки = НачалоМесяца(получитьТекущуюДатуНаСервере());
    ЭтотОбъект.МесяцСтрокой = Формат(ЭтотОбъект.ПериодОбработки, получитьФорматПериода());
КонецПроцедуры

&НаКлиенте
Процедура очиститьЗначенияЧисловыхПоказателей()
    ЭтотОбъект.ВыручкаЧисло = 0;
    ЭтотОбъект.СреднийЧек = 0;
    ЭтотОбъект.ВсегоЗаписей = 0;
    ЭтотОбъект.Завершенных = 0;
    ЭтотОбъект.ЗавершенныхПроцентСтрока = "";
КонецПроцедуры

&НаКлиенте
Процедура заполнитьЧисловыеПоказатели(Знач датаНачала = Неопределено, Знач датаОкончания = Неопределено)
    датаНачала = ?(датаНачала = Неопределено, ЭтотОбъект.ПериодОбработки, датаНачала);
    датаОкончания = ?(датаОкончания = Неопределено, КонецМесяца(датаНачала), датаОкончания);

    данныеПоказателей = получитьДанныеЧисловыхПоказателейНаСервере(датаНачала, датаОкончания);
    Если данныеПоказателей = Неопределено Тогда
        очиститьЗначенияЧисловыхПоказателей();
        Возврат;
    КонецЕсли;

    ЭтотОбъект.ВыручкаЧисло = данныеПоказателей.Выручка;
    ЭтотОбъект.СреднийЧек = ?(данныеПоказателей.Завершенных > 0,
            ОКР(данныеПоказателей.Выручка / данныеПоказателей.Завершенных, 2), 0);
    ЭтотОбъект.ВсегоЗаписей = данныеПоказателей.ВсегоЗаписей;
    ЭтотОбъект.Завершенных = данныеПоказателей.Завершенных;

    Если ЭтотОбъект.ВсегоЗаписей > 0 Тогда
        процентЗавершенных = ОКР((100 * ЭтотОбъект.Завершенных / ЭтотОбъект.ВсегоЗаписей), 2);
        ЭтотОбъект.ЗавершенныхПроцентСтрока = СтрШаблон("Это %1%% от всех записей", процентЗавершенных);
    Иначе
        ЭтотОбъект.ЗавершенныхПроцентСтрока = "В этом периоде нет записей клиентов!";
    КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура заполнитьДиаграммуВыручки()
    датаНачала = ЭтотОбъект.ПериодОбработки;
    датаОкончания = КонецМесяца(ЭтотОбъект.ПериодОбработки);

    продажиПоДням = получитьДанныеПродажПоДнямНаСервере(датаНачала, датаОкончания);

    ЭтотОбъект.ДиаграммаВыручка.Обновление = Ложь;
    ЭтотОбъект.ДиаграммаВыручка.Очистить();

    Если продажиПоДням <> Неопределено Тогда
        серияДанныхОборот = ДиаграммаВыручка.Серии.Добавить("Оборот");
        серияДанныхОборот.Цвет = WebЦвета.ЛососьСветлый;

        Для Каждого элемент Из продажиПоДням Цикл
            период_ = элемент.Период;
            сумма_ = элемент.Сумма;

            точкаДиаграммы = ЭтотОбъект.ДиаграммаВыручка.Точки.Добавить(период_);
            точкаДиаграммы.Текст = Формат(период_, "ДФ=dd.MM.yy");
            точкаДиаграммы.Расшифровка = период_;
            подсказка = СтрШаблон("Выручка %1 на %2", сумма_, Формат(период_, получитьФорматПериода()));
            ЭтотОбъект.ДиаграммаВыручка.УстановитьЗначение(
                точкаДиаграммы, серияДанныхОборот, сумма_, точкаДиаграммы.Расшифровка, подсказка);
        КонецЦикла;
    КонецЕсли;

    ЭтотОбъект.ДиаграммаВыручка.Обновление = Истина;
КонецПроцедуры

&НаКлиенте
Процедура заполнитьКруговыеДиаграммы()
    заполнитьДиаграммуПоИсточникамИнформации();
    заполнитьДиаграммуПоСотрудникам();
    заполнитьДиаграммуПоУслугам();
КонецПроцедуры

&НаКлиенте
Процедура заполнитьКруговуюДиаграмму(Знач данныеДляЗаполнения, Знач диаграмма, Знач имяОсиЗначений)
    диаграмма.Обновление = Ложь;
    диаграмма.Очистить();

    Если данныеДляЗаполнения <> Неопределено Тогда
        точкаДиаграммы = диаграмма.Точки.Добавить(имяОсиЗначений);
        точкаДиаграммы.Текст = имяОсиЗначений;
        точкаДиаграммы.ПриоритетЦвета = Ложь;

        Для Каждого элемент Из данныеДляЗаполнения Цикл
            серияДанных = диаграмма.Серии.Добавить(элемент.Ключ);
            диаграмма.УстановитьЗначение(
                точкаДиаграммы, серияДанных, элемент.Значение, Строка(элемент.Значение));
        КонецЦикла;
    КонецЕсли;

    диаграмма.Обновление = Истина;
КонецПроцедуры

&НаКлиенте
Процедура заполнитьДиаграммуПоУслугам()
    датаНачала = ЭтотОбъект.ПериодОбработки;
    датаОкончания = КонецМесяца(ЭтотОбъект.ПериодОбработки);

    продажиУслуг = получитьДолиПродажУслугНаСервере(датаНачала, датаОкончания, 0.1);
    заполнитьКруговуюДиаграмму(продажиУслуг,
        ЭтотОбъект.ДиаграммаПоУслугам, "Сумма");
КонецПроцедуры

&НаКлиенте
Процедура заполнитьДиаграммуПоИсточникамИнформации()
    датаНачала = ЭтотОбъект.ПериодОбработки;
    датаОкончания = КонецМесяца(ЭтотОбъект.ПериодОбработки);

    источникИнформацииПокупок = получитьИсточникиИнформацииПокупокНаСервере(датаНачала, датаОкончания);
    заполнитьКруговуюДиаграмму(источникИнформацииПокупок,
        ЭтотОбъект.ДиаграммаПоРекламнымИсточникам, "Количество");
КонецПроцедуры

&НаКлиенте
Процедура заполнитьДиаграммуПоСотрудникам()
    датаНачала = ЭтотОбъект.ПериодОбработки;
    датаОкончания = КонецМесяца(ЭтотОбъект.ПериодОбработки);

    продажиСотрудников = получитьПродажиПоСотрудникамНаСервере(датаНачала, датаОкончания);
    заполнитьКруговуюДиаграмму(продажиСотрудников,
        ЭтотОбъект.ДиаграммаВыручкаПоСотрудникам, "Сумма");
КонецПроцедуры

#Область ЗапросыДанных
&НаСервереБезКонтекста
Функция получитьДанныеЧисловыхПоказателейНаСервере(Знач датаНачала, Знач датаОкончания)
    Возврат Обработки.МониторРуководителя.ПолучитьДанныеЧисловыхПоказателей(датаНачала, датаОкончания);
КонецФункции

&НаСервереБезКонтекста
Функция получитьДанныеПродажПоДнямНаСервере(Знач датаНачала, Знач датаОкончания)
    Возврат Обработки.МониторРуководителя.ПолучитьДанныеПродажПоДням(датаНачала, датаОкончания);
КонецФункции

&НаСервереБезКонтекста
Функция получитьДолиПродажУслугНаСервере(Знач датаНачала, Знач датаОкончания, Знач доляПродаж)
    Возврат Обработки.МониторРуководителя.ПолучитьДолиПродажУслуг(датаНачала, датаОкончания, доляПродаж);
КонецФункции

&НаСервереБезКонтекста
Функция получитьИсточникиИнформацииПокупокНаСервере(Знач датаНачала, Знач датаОкончания, Знач представлениеNull = "Не указан")
    Возврат Обработки.МониторРуководителя.ПолучитьИсточникиИнформацииПокупок(датаНачала, датаОкончания, представлениеNull);
КонецФункции

&НаСервереБезКонтекста
Функция получитьПродажиПоСотрудникамНаСервере(Знач датаНачала, Знач датаОкончания)
    Возврат Обработки.МониторРуководителя.ПолучитьПродажиПоСотрудникам(датаНачала, датаОкончания);
КонецФункции
#КонецОбласти // ЗапросыДанных

&НаСервереБезКонтекста
Функция получитьТекущуюДатуНаСервере()
    Возврат ТекущаяДатаСеанса();
КонецФункции

&НаКлиенте
Функция получитьФорматПериода()
    Возврат "ДФ='ММММ гггг'";
КонецФункции

&НаСервереБезКонтекста
Функция получитьНовостиНаСервере(Знач текстЗапроса, Знач датаЗагрузки, Знач язык, Знач количество)
    количество = Мин(Макс(количество, 1), 100);
    Возврат Обработки.МониторРуководителя.ЗагрузитьНовости(текстЗапроса, датаЗагрузки, язык, количество);
КонецФункции

&НаСервереБезКонтекста
Функция получитьКурсыВалютНаСервере(Знач датаЗагрузки)
    Возврат Обработки.МониторРуководителя.ЗагрузитьКурсыВалютПоДаннымЦентробанка(датаЗагрузки);
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции

#Область Инициализация

&НаКлиенте
Процедура инициализацияСтраницыНовостей()
    // BSLLS:DeprecatedCurrentDate-off
    ЭтотОбъект.НовостиДатаЗагрузки = ТекущаяДата();
    ЭтотОбъект.НовостиКоличество = 10;
    ЭтотОбъект.НовостиЯзыкПоиска = "ru";
    ЭтотОбъект.НовостиСтрокаПоиска = "Бизнес";
КонецПроцедуры

#КонецОбласти // Инициализация
