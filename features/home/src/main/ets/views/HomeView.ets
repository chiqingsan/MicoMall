import { Log } from '@abner/log'
import { BreakPointKey, BreakPointType, httpInstance, HttpResponse, MkLoading } from '@mk/basic/Index'
import { DiscountGoodsComp, DiscountType } from '../components/DiscountGoodsComp'
import { MkGoods } from '@mk/basic/src/main/ets/components/MkGoods'
import { ApiResult, Banner, CategoryItem, MkGoodsItem, Params } from '../models'
import { AxiosResponse } from '@ohos/axios'
import {
  getBannerApi,
  getCategoryApi,
  getHotApi,
  getNewApi,
  getOneApi,
  getPreferenceApi,
  getRecommendApi
} from '../apis'
import { promptAction, router } from '@kit.ArkUI'


@Component
export struct HomeView {
  @StorageProp("topHeight") topHeight: number = 0
  // 轮播图
  @State banners: Banner[] = []
  // 分类
  @State categories: CategoryItem[] = []
  // 特惠推荐
  @State saleGoods: MkGoodsItem[] = []
  // 爆款推荐
  @State hotGoods: MkGoodsItem[] = []
  // 一站买全
  @State oneGoods: MkGoodsItem[] = []
  // 新鲜好物
  @State newGoods: MkGoodsItem[] = []
  // 推荐商品
  @State recommendGoods: MkGoodsItem[] = []
  @StorageProp(BreakPointKey) breakPointKey: string = "sm"
  @State isLoading: boolean = false
  @State refresh: boolean = false
  page: number = 1
  numberPerPage: number = 8

  // 生成模拟数据
  mockData() {
    // this.banners = new Array(6).fill({
    //   id: "42",
    //   imgUrl: "https://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/meikou/banner/nuandong_sj.png",
    //   hrefUrl: "/category/1181622006",
    //   type: "1"
    // })

    this.categories = new Array(10).fill({
      id: "1181622001",
      name: "气质女装",
      picture: "https://yjy-teach-oss.oss-cn-beijing.aliyuncs.com/meikou/c1/qznz.png"
    })

    this.saleGoods = new Array(6).fill({
      "id": "1111002",
      "name": "剪出精致感，金致圆柄复古剪刀",
      "desc": "轻薄设计，简约大方",
      "price": "9.90",
      "picture": "https://yanxuan-item.nosdn.127.net/4c6a9c8a579b00e5e9c7b002d15a33a2.jpg",
      "orderNum": 172
    },)

    this.hotGoods = new Array(8).fill({
      "id": "1135059",
      "name": "手工八年老陈醋500毫升",
      "desc": "地道醇香，醋酸浓郁",
      "price": "30.00",
      "picture": "https://yanxuan-item.nosdn.127.net/77da20e77b02830a26f931901ac1a9e0.png",
      "orderNum": 147
    },)
    this.oneGoods = new Array(8).fill({
      "id": "1135079",
      "name": "免浸泡，12种谷物一次同享，五谷米400克",
      "desc": "无需浸泡，同煮同熟",
      "price": "9.90",
      "picture": "https://yanxuan-item.nosdn.127.net/bfe70bd66efe94f2f18061c707d2a097.png",
      "orderNum": 144
    })
    this.newGoods = new Array(8).fill({
      "id": "4027998",
      "name": "亮碟多效合一洗涤块495g",
      "desc": "洗碗机专用，强力去污",
      "price": "69.90",
      "picture": "https://yanxuan-item.nosdn.127.net/e07c2b63765cf9f4a46d489c6e09c1c1.jpg",
      "orderNum": 643
    })

    this.recommendGoods = new Array(8).fill({
      "id": "4033959",
      "name": "3秒快速拆琴轻松保养odin奥丁12半音阶口琴",
      "price": 329,
      "picture": "https://yanxuan-item.nosdn.127.net/937a8e46a9284e8f7e00e13911ecfbe7.png",
      "payCount": 0
    })
  }

  // 请求接口数据
  async getData() {

    const PromiseArr =
      [getBannerApi(), getCategoryApi(), getPreferenceApi(), getHotApi(), getOneApi(), getNewApi(),
        getRecommendApi(this.page * this.numberPerPage)]
    const resArr = await Promise.all(PromiseArr)

    // banner数据
    this.banners = resArr[0].data.result as Banner[]

    // 分类
    this.categories = resArr[1].data.result as CategoryItem[]

    // 特惠推荐
    this.saleGoods = (resArr[2].data.result as ApiResult).subTypes[0].goodsItems.items

    // 爆款推荐
    this.hotGoods = (resArr[3].data.result as ApiResult).subTypes[0].goodsItems.items

    // 一站买全
    this.oneGoods = (resArr[4].data.result as ApiResult).subTypes[0].goodsItems.items

    // 新鲜好物
    this.newGoods = resArr[5].data.result as MkGoodsItem[]

    // 推荐列表
    this.recommendGoods = resArr[6].data.result as MkGoodsItem[]


    // 保存分类数据,方便其他页面使用
    AppStorage.setOrCreate("categories", this.categories)
  }

  getSpace() {
    return new BreakPointType({
      sm: 14,
      md: 36,
      lg: 72
    }).getValue(this.breakPointKey) as number
  }

  // 加载更多
  async getMore() {
    if (this.recommendGoods.length <= 30) {
      this.page++
      const res = await getRecommendApi(this.page * this.numberPerPage)
      this.recommendGoods = res.data.result
    } else {
      promptAction.showToast({ message: "已经到底啦~" })
    }
  }

  async aboutToAppear(): Promise<void> {
    this.isLoading = true
    await this.getData()
    this.isLoading = false
  }

  async refreshTheData() {
    if (this.refresh) {
      // 重置页码
      this.page = 1
      await this.getData()
      this.refresh = false
    }
  }

  @Builder
  DiscountBuilder(params: Params) {

    Column() {
      Row({ space: 10 }) {
        Text(params.title)
          .fontColor($r('app.color.black'))
          .fontSize(14)
        Text(params.subTitle)
          .fontColor($r('app.color.text'))
          .fontSize(11)
      }
      .width('100%')
      .margin({ bottom: 10 })

      List({ space: 10 }) {
        ForEach(params.list, (item: MkGoodsItem) => {
          ListItem() {
            DiscountGoodsComp({ type: DiscountType.DISCOUNT, goods: item })
          }
        })
      }
      .width('100%')
      .height(116)
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
    }
    .height(160)
    .layoutWeight(1)
    .padding(10)
    .backgroundColor(params.bg)
    .borderRadius(8)
  }

  @Builder
  refreshTheEffect() {
    Column() {
      MkLoading()
    }
    .padding(20)
  }

  build() {
    if (this.isLoading) {
      MkLoading()
    } else {
      Refresh({
        refreshing: $$this.refresh,
        builder: this.refreshTheEffect
      }) {
        Scroll() {
          Column() {
            // 轮播图 + 搜索
            Stack({ alignContent: Alignment.Top }) {
              Swiper() {
                ForEach(this.banners, (item: Banner) => {
                  Image(item.imgUrl)
                })
              }
              .displayCount(new BreakPointType({
                sm: 1,
                md: 2,
                lg: 3
              }).getValue(this.breakPointKey))
              .itemSpace(new BreakPointType({
                sm: 0,
                md: 10,
                lg: 20
              }).getValue(this.breakPointKey))
              .indicator(
                this.breakPointKey === "sm" ? DotIndicator.dot()
                  .itemWidth(8)
                  .itemHeight(4)
                  .color('#33191919')
                  .selectedItemWidth(24)
                  .selectedItemHeight(4)
                  .selectedColor('#191919') : false
              )


              Row() {
                Row({ space: 4 }) {
                  Image($r('app.media.ic_public_search'))
                    .width(16)
                    .height(16)
                    .fillColor($r('app.color.white'))
                  Text('搜索...')
                    .fontSize(14)
                    .fontColor($r('app.color.white'))
                }
                .backgroundColor('#33191919')
                .width('100%')
                .height(40)
                .borderRadius(20)
                .padding({ left: 12 })
                .onClick(() => {
                  router.pushUrl({ url: "pages/SearchPage" })
                })
              }
              .padding({ left: 16, right: 16, top: this.topHeight })
            }
            .width('100%')


            // 分类
            Column({ space: 10 }) {
              // 分类
              List({ space: this.getSpace() }) {
                ForEach(this.categories, (item: CategoryItem) => {
                  ListItem() {
                    Column() {
                      Image(item.picture)
                        .width(56)
                        .aspectRatio(1)
                      Text(item.name)
                        .fontSize(10)
                        .fontColor('#CC191919')
                    }
                    .width(60)
                    .height(80)
                    .borderRadius(30)

                    .clip(true)
                    .backgroundImage(item.picture)
                    .backgroundImageSize(ImageSize.Contain)
                    .backgroundImagePosition(Alignment.Center)
                    .backgroundBlurStyle(
                      BlurStyle.BACKGROUND_ULTRA_THICK,
                      { scale: 0.25 }
                    )
                  }
                })
              }
              .width('100%')
              .height(92)
              .scrollBar(BarState.Off)
              .listDirection(Axis.Horizontal)
              .alignListItem(ListItemAlign.Center)

              // 特惠推荐
              Column({ space: 10 }) {
                Image($r('app.media.home_cmd_title'))
                  .width(150)
                  .height(20)
                Row() {
                  Image($r('app.media.home_cmd_inner'))
                    .width(86)
                    .height(116)
                  List({ space: this.getSpace() }) {
                    ForEach(this.saleGoods, (item: MkGoodsItem) => {
                      ListItem() {
                        DiscountGoodsComp({ goods: item })
                      }
                    })
                  }
                  .layoutWeight(1)
                  .width('100%')
                  .height(116)
                  .backgroundColor($r('app.color.white'))
                  .borderRadius({
                    topRight: 8,
                    bottomRight: 8
                  })
                  .padding({ right: 10, left: 10 })
                  .scrollBar(BarState.Off)
                  .listDirection(Axis.Horizontal)
                }
              }
              .width('100%')
              .height(166)
              .backgroundImage($r('app.media.home_cmd_sm'))
              .backgroundImageSize(ImageSize.Cover)
              .borderRadius(8)
              .padding(10)
              .alignItems(HorizontalAlign.Start)

              // 爆款推荐+一站买全
              Row({ space: 10 }) {
                this.DiscountBuilder({
                  title: '爆款推荐',
                  subTitle: '最受欢迎',
                  bg: '#EDF1FB',
                  list: this.hotGoods
                })
                this.DiscountBuilder({
                  title: '一站买全',
                  subTitle: '精心优选',
                  bg: '#FCF6EA',
                  list: this.oneGoods
                })
              }

              // 新鲜好物
              Column({ space: 10 }) {
                Image($r('app.media.home_new'))
                  .width(146)
                  .height(19)
                List({ space: this.getSpace() }) {
                  ForEach(this.newGoods, (item: MkGoodsItem) => {
                    ListItem() {
                      DiscountGoodsComp({ type: DiscountType.NEW, goods: item })
                    }
                  })
                }
                .width('100%')
                .height(116)
                .scrollBar(BarState.Off)
                .listDirection(Axis.Horizontal)
              }
              .width('100%')
              .height(156)
              .padding(10)
              .backgroundColor('#F7EFF5')
              .borderRadius(8)
              .alignItems(HorizontalAlign.Start)

              // 推荐商品
              WaterFlow() {
                ForEach(this.recommendGoods, (item: MkGoodsItem) => {
                  FlowItem() {
                    MkGoods({ goods: item })
                  }
                }, (item: MkGoodsItem) => item.id)
              }
              .columnsTemplate(new BreakPointType({
                sm: "1fr 1fr",
                md: "1fr 1fr 1fr",
                lg: "1fr 1fr 1fr 1fr"
              }).getValue(this.breakPointKey))
              .columnsGap(8)
              .rowsGap(10)

            }
            .padding({
              left: 8,
              right: 8,
              bottom: 10,
              top: 10
            })
          }
        }
        .scrollBar(BarState.Off)
        .onReachEnd(() => {
          this.getMore()
        })
      }
      .onRefreshing(() => {
        this.refreshTheData()
      })
    }
  }
}