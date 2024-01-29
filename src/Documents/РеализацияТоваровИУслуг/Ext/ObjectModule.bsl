﻿#Область ПрограммныйИнтерфейс

// Обновляет поле СуммаДокумента.\
// Для корректной рабаты все суммы по строкам ТЧ должны быть предварительно рассчитаны.\
// =========================\
// [примечание разработчика] - в текущей реализации (Спринт 3) не используется.
// Обновление суммы документа выполняется в процессе заполнения формы.
Процедура ОбновитьСуммуДокумента() Экспорт
    опцииРасчета_ = Документы.РеализацияТоваровИУслуг.ПолучитьПоляДляРасчетаСуммыДокумента();
    сумма_ = РаботаСДокументамиКлиентСервер.РассчитатьСуммуДокумента(ЭтотОбъект, опцииРасчета_);
    СуммаДокумента = сумма_;
КонецПроцедуры

#КонецОбласти // ПрограммныйИнтерфейс

#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(данныеЗаполнения, __, ___)
    Если ТипЗнч(данныеЗаполнения) = Тип("ДокументСсылка.ЗаписьКлиента") Тогда
        ДатаОказанияУслуги = данныеЗаполнения.ДатаЗаписи;
        Клиент = данныеЗаполнения.Клиент;
        Сотрудник = данныеЗаполнения.Сотрудник;
        Основание = данныеЗаполнения.Ссылка;

        Для Каждого текСтрокаУслуги Из данныеЗаполнения.Услуги Цикл
            новаяСтрока = Услуги.Добавить();
            новаяСтрока.Стоимость = текСтрокаУслуги.Стоимость;
            новаяСтрока.Услуга = текСтрокаУслуги.Услуга;
            СуммаДокумента = СуммаДокумента + текСтрокаУслуги.Стоимость;
        КонецЦикла;
    КонецЕсли;

    РаботаСДокументами.ЗаполнитьПолеАвторДокументаНаСервере(ЭтотОбъект);
КонецПроцедуры

Процедура ОбработкаПроведения(отказ, __)
    очиститьДвиженияДокумента();
    выполнитьВсеДвиженияДокумента(отказ);
    Если НЕ отказ Тогда
        записатьДвижения();
    КонецЕсли;
КонецПроцедуры

#КонецОбласти // ОбработчикиСобытий

#Область СлужебныеПроцедурыИФункции

#Область ЗапросыДанных
Функция получитьВыборкуДокументНоменклатураОстатки(менеджерТаблиц)
    запросОстатков = Новый Запрос;
    запросОстатков.МенеджерВременныхТаблиц = менеджерТаблиц;
    запросОстатков.УстановитьПараметр("Ссылка", Ссылка);
    запросОстатков.УстановитьПараметр("МоментВремени", Новый Граница(МоментВремени()));

    текстЗапросаТоваровИУслугДокумента =
        "ВЫБРАТЬ
        |	РеализацияТоваровИУслугТовары.Номенклатура КАК Номенклатура,
        |	РеализацияТоваровИУслугТовары.Склад КАК Склад,
        |	СУММА(РеализацияТоваровИУслугТовары.Количество) КАК Количество,
        |	СУММА(РеализацияТоваровИУслугТовары.Сумма) КАК Сумма
        |ПОМЕСТИТЬ ВТ_Товары
        |ИЗ
        |	Документ.РеализацияТоваровИУслуг.Товары КАК РеализацияТоваровИУслугТовары
        |ГДЕ
        |	РеализацияТоваровИУслугТовары.Ссылка = &Ссылка
        |
        |СГРУППИРОВАТЬ ПО
        |	РеализацияТоваровИУслугТовары.Номенклатура,
        |	РеализацияТоваровИУслугТовары.Склад
        |
        |ОБЪЕДИНИТЬ ВСЕ
        |
        |ВЫБРАТЬ
        |	РеализацияТоваровИУслугУслуги.Номенклатура,
        |	NULL,
        |	СУММА(РеализацияТоваровИУслугУслуги.Количество),
        |	СУММА(РеализацияТоваровИУслугУслуги.Сумма)
        |ИЗ
        |	Документ.РеализацияТоваровИУслуг.Услуги КАК РеализацияТоваровИУслугУслуги
        |ГДЕ
        |	РеализацияТоваровИУслугУслуги.Ссылка = &Ссылка
        | СГРУППИРОВАТЬ ПО
        |	РеализацияТоваровИУслугУслуги.Номенклатура
        |
        |ИНДЕКСИРОВАТЬ ПО
        |	Номенклатура,
        |	Склад
        |;
        |";

    текстЗапросаОстатков =
        "ВЫБРАТЬ
        |	ВТ_Товары.Номенклатура КАК Номенклатура,
        |	ВЫБОР
        |		КОГДА ВТ_Товары.Номенклатура.ТипНоменклатуры = ЗНАЧЕНИЕ(Перечисление.ТипыНоменклатуры.Услуга)
        |			ТОГДА ЛОЖЬ
        |		ИНАЧЕ ИСТИНА
        |	КОНЕЦ КАК ЭтоТовар,
        |	ВТ_Товары.Номенклатура.Представление КАК НоменклатураПредставление,
        |	ВТ_Товары.Количество КАК КоличествоВДокументе,
        |	ВТ_Товары.Сумма КАК СуммаВДокументе,
        |	ВТ_Товары.Склад КАК Склад,
        |	ТоварыНаСкладахОстатки.СрокГодности КАК СрокГодности,
        |	ЕстьNULL(ТоварыНаСкладахОстатки.КоличествоОстаток, 0) КАК КоличествоОстаток,
        |	ЕстьNULL(ТоварыНаСкладахОстатки.СуммаОстаток, 0) КАК СуммаОстаток,
        |	ВТ_Товары.Номенклатура.СтатьяЗатрат КАК СтатьяЗатрат
        |ИЗ
        |	ВТ_Товары КАК ВТ_Товары
        |		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыНаСкладах.Остатки(
        |			&МоментВремени,
        |			(Номенклатура, Склад) В (
        |				ВЫБРАТЬ
        |					ВТ_Товары.Номенклатура,
        |					ВТ_Товары.Склад
        |				ИЗ
        |					ВТ_Товары КАК ВТ_Товары)) КАК ТоварыНаСкладахОстатки
        |		ПО ВТ_Товары.Номенклатура = ТоварыНаСкладахОстатки.Номенклатура
        |			И ВТ_Товары.Склад = ТоварыНаСкладахОстатки.Склад
        |
        |УПОРЯДОЧИТЬ ПО
        |	ТоварыНаСкладахОстатки.СрокГодности
        |ИТОГИ
        |	МАКСИМУМ(КоличествоВДокументе),
        |	МАКСИМУМ(СуммаВДокументе),
        |	СУММА(КоличествоОстаток)
        |ПО
        |	Номенклатура
        |";

    запросОстатков.Текст = СтрШаблон("%1%2", текстЗапросаТоваровИУслугДокумента, текстЗапросаОстатков);

    Возврат запросОстатков.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
КонецФункции

Функция получитьВыборкуПревышенияОстатковЗаказыКлиентов(менеджерТаблиц) // => Выборка | Неопределено
    запросЗаказыКлиентовОстатки = Новый Запрос;
    запросЗаказыКлиентовОстатки.МенеджерВременныхТаблиц = менеджерТаблиц;

    запросЗаказыКлиентовОстатки.УстановитьПараметр("МоментВремени", Новый Граница(МоментВремени()));
    запросЗаказыКлиентовОстатки.УстановитьПараметр("Клиент", Клиент);
    запросЗаказыКлиентовОстатки.УстановитьПараметр("ДатаЗаписи", ДатаОказанияУслуги);

    запросЗаказыКлиентовОстатки.Текст =
        "ВЫБРАТЬ
        |	ЗаказыКлиентовОстатки.КоличествоОстаток КАК КоличествоОстаток,
        |	ЗаказыКлиентовОстатки.Клиент КАК Клиент,
        |	ЗаказыКлиентовОстатки.ДатаЗаписи КАК ДатаЗаписи,
        |	ЗаказыКлиентовОстатки.Клиент.Представление КАК КлиентПредставление,
        |	ЗаказыКлиентовОстатки.Номенклатура КАК Номенклатура,
        |	ЗаказыКлиентовОстатки.Номенклатура.Представление КАК НоменклатураПредставление
        |ИЗ
        |	РегистрНакопления.ЗаказыКлиентов.Остатки(
        |			&МоментВремени,
        |			Клиент = &Клиент
        |				И ДатаЗаписи = &ДатаЗаписи
        |				И Номенклатура В
        |					(ВЫБРАТЬ
        |						ВТ_Товары.Номенклатура
        |					ИЗ
        |						ВТ_Товары КАК ВТ_Товары
        |					ГДЕ
        |						ВТ_Товары.Номенклатура.ТипНоменклатуры = ЗНАЧЕНИЕ(Перечисление.ТипыНоменклатуры.Услуга))) КАК ЗаказыКлиентовОстатки
        |ГДЕ
        |	ЗаказыКлиентовОстатки.КоличествоОстаток < 0
        |";

    результатЗапроса = запросЗаказыКлиентовОстатки.Выполнить();
    Возврат ?(результатЗапроса.Пустой(), Неопределено, результатЗапроса.Выбрать());
КонецФункции
#КонецОбласти // ЗапросыДанных

#Область Движения
Процедура записатьДвижения()
    Движения.ТоварыНаСкладах.Записывать = Истина;
    Движения.Продажи.Записывать = Истина;
    Движения.УчетЗатрат.Записывать = Истина;

    Движения.ЗаказыКлиентов.Записывать = Истина;
    Движения.ЗаказыКлиентов.Записать();
КонецПроцедуры

Процедура очиститьДвиженияДокумента()
    Движения.ТоварыНаСкладах.Записывать = Истина;
    Движения.Продажи.Записывать = Истина;
    Движения.УчетЗатрат.Записывать = Истина;

    Движения.Записать();
КонецПроцедуры

Процедура выполнитьВсеДвиженияДокумента(отказ = Ложь)
    менеджерТаблиц = Новый МенеджерВременныхТаблиц;

    блокировка = получитьБлокировкуИзмененияТоварыНаСкладах();
    блокировка.Заблокировать();

    выборкаНоменклатураДокумента = получитьВыборкуДокументНоменклатураОстатки(менеджерТаблиц);
    Пока выборкаНоменклатураДокумента.Следующий() Цикл
        этоТовар = выборкаНоменклатураДокумента.ЭтоТовар;
        Если этоТовар Тогда
            стоимостьОбщая = 0;

            Если проверитьПревышениеОстатков(
                    выборкаНоменклатураДокумента.КоличествоВДокументе,
                    выборкаНоменклатураДокумента.КоличествоОстаток,
                    выборкаНоменклатураДокумента.НоменклатураПредставление) Тогда
                отказ = Истина;
                Продолжить;
            КонецЕсли;

            несписанныйОстаток = выборкаНоменклатураДокумента.КоличествоВДокументе;
            выборкаНоменклатураДокументаПоСрокуГодности = выборкаНоменклатураДокумента.Выбрать();
            Пока выборкаНоменклатураДокументаПоСрокуГодности.Следующий() И несписанныйОстаток > 0 Цикл
                стоимостьОбщая = стоимостьОбщая + выполнитьДвижениеТоварыНаСкладахРасход(
                        выборкаНоменклатураДокументаПоСрокуГодности,
                        несписанныйОстаток);
            КонецЦикла;

            выполнитьДвижениеУчетЗатратОборот(выборкаНоменклатураДокумента, стоимостьОбщая);
        Иначе
            Если выполнитьКонтрольОстатковДляЗаказыКлиентов(менеджерТаблиц) Тогда
                выполнитьДвижениеЗаказыКлиентовРасход(выборкаНоменклатураДокумента);
            Иначе
                отказ = Истина;
                Продолжить;
            КонецЕсли;
        КонецЕсли;
        выполнитьДвижениеПродажиОборот(выборкаНоменклатураДокумента);
    КонецЦикла;
КонецПроцедуры

Процедура выполнитьДвижениеПродажиОборот(выборкаНоменклатураДокумента)
    движение = Движения.Продажи.Добавить();
    движение.Период = Дата;
    движение.Номенклатура = выборкаНоменклатураДокумента.Номенклатура;
    движение.Сотрудник = Сотрудник;
    движение.Клиент = Клиент;
    движение.Сумма = выборкаНоменклатураДокумента.СуммаВДокументе;
    движение.Количество = выборкаНоменклатураДокумента.КоличествоВДокументе;
КонецПроцедуры

Функция выполнитьДвижениеТоварыНаСкладахРасход(выборкаНоменклатураДокументаДетальные, текущийОстаток = 0) // => Число
    доступноДляСписания = Мин(выборкаНоменклатураДокументаДетальные.КоличествоОстаток, текущийОстаток);

    движение = Движения.ТоварыНаСкладах.ДобавитьРасход();
    движение.Период = Дата;
    движение.Номенклатура = выборкаНоменклатураДокументаДетальные.Номенклатура;
    движение.Склад = выборкаНоменклатураДокументаДетальные.Склад;
    движение.СрокГодности = выборкаНоменклатураДокументаДетальные.СрокГодности;
    движение.Количество = доступноДляСписания;
    Если доступноДляСписания = выборкаНоменклатураДокументаДетальные.КоличествоОстаток Тогда
        движение.Сумма = выборкаНоменклатураДокументаДетальные.СуммаОстаток;
    Иначе
        движение.Сумма = доступноДляСписания / выборкаНоменклатураДокументаДетальные.КоличествоОстаток
            * выборкаНоменклатураДокументаДетальные.СуммаОстаток;
    КонецЕсли;

    текущийОстаток = текущийОстаток - доступноДляСписания;

    Возврат движение.Сумма;
КонецФункции

Процедура выполнитьДвижениеУчетЗатратОборот(выборкаНоменклатураДокумента, стоимостьОбщая)
    движение = Движения.УчетЗатрат.Добавить();
    движение.Период = Дата;
    движение.СтатьяЗатрат = выборкаНоменклатураДокумента.СтатьяЗатрат;
    движение.Сумма = стоимостьОбщая;
КонецПроцедуры

Процедура выполнитьДвижениеЗаказыКлиентовРасход(выборкаНоменклатураДокумента)
    движение = Движения.ЗаказыКлиентов.Добавить();
    движение.Номенклатура = выборкаНоменклатураДокумента.Номенклатура;
    движение.ВидДвижения = ВидДвиженияНакопления.Расход;
    движение.Период = Дата;
    движение.Клиент = Клиент;
    движение.ДатаЗаписи = ДатаОказанияУслуги;
    движение.Количество = выборкаНоменклатураДокумента.КоличествоВДокументе;
    движение.Сумма = выборкаНоменклатураДокумента.СуммаВДокументе;
КонецПроцедуры

// Выполняет проверку достаточности остатков по Номенклатуре.\
// В случае отсутствия достаточного количества остатков - оповещает Пользователя.
//
// Параметры:
//	количествоВДокументе - Число - Количество Номенклатуры в документе для движения
//	остаток - Число - Остаток Номенклатуры на складах
//	наименованиеНоменклатуры - Строка - Наименование Номенклатуры, используется в тексте сообщения
//
// Возвращаемое значение:
//	Булево - Истина если остатков нехватает, иначе Ложь
//
Функция проверитьПревышениеОстатков(Знач количествоВДокументе, Знач остаток, Знач наименованиеНоменклатуры)
    превышениеОстатковНоменклатуры = количествоВДокументе - остаток;
    Если превышениеОстатковНоменклатуры > 0 Тогда
        сообщение = Новый СообщениеПользователю;
        сообщение.Текст = СтрШаблон("Превышение остатка по номенклатуре: ""%1"" в количестве: ""%2""",
                наименованиеНоменклатуры, превышениеОстатковНоменклатуры);
        сообщение.Сообщить();
        Возврат Истина;
    КонецЕсли;
    Возврат Ложь;
КонецФункции

// Выполняет контроль остатков в РегистрНакопления.ЗаказыКлиентов.\
//
// Параметры:
//	менеджерТаблиц - МенеджерВременныхТаблиц - должен содержать ранее заполненную
//	временную таблицу ВТ_Товары
//
// Возвращаемое значение:
//	Булево - Истина: если превышения остатков нет (Успех),
//	Ложь если обнаружены превышения остатков (Проверка не пройдена).
//
Функция выполнитьКонтрольОстатковДляЗаказыКлиентов(менеджерТаблиц) // => Булево
    Движения.ЗаказыКлиентов.БлокироватьДляИзменения = Истина;
    Движения.ЗаказыКлиентов.Записать();

    выборкаПревышенияОстатков = получитьВыборкуПревышенияОстатковЗаказыКлиентов(менеджерТаблиц);

    Если выборкаПревышенияОстатков = Неопределено Тогда
        Возврат Истина; // Превышения остатков нет - Успех.
    КонецЕсли;

    Пока выборкаПревышенияОстатков.Следующий() Цикл
        Сообщение = Новый СообщениеПользователю;
        Сообщение.Текст =
            СтрШаблон("Услуга: ""%1"" для клиента: ""%2"" на дату: ""%3"" уже была обработана или не была найдена такая запись!",
                выборкаПревышенияОстатков.НоменклатураПредставление, выборкаПревышенияОстатков.КлиентПредставление,
                Формат(выборкаПревышенияОстатков.ДатаЗаписи, "ДФ=dd.MM.yy"));
        Сообщение.Сообщить();
    КонецЦикла;

    Возврат Ложь; // Обнаружены превышения остатков - Проверка не пройдена
КонецФункции
#КонецОбласти // Движения

Функция получитьБлокировкуИзмененияТоварыНаСкладах() // => БлокировкаДанных
    блокировка = Новый БлокировкаДанных;
    элементБлокировки = блокировка.Добавить("РегистрНакопления.ТоварыНаСкладах");
    элементБлокировки.Режим = РежимБлокировкиДанных.Исключительный;
    элементБлокировки.ИсточникДанных = Товары;
    элементБлокировки.ИспользоватьИзИсточникаДанных("Номенклатура", "Номенклатура");
    элементБлокировки.ИспользоватьИзИсточникаДанных("Склад", "Склад");

    Возврат блокировка;
КонецФункции

#КонецОбласти // СлужебныеПроцедурыИФункции
