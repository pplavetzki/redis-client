package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/go-redis/redis/v8"
	"go.uber.org/zap"
)

var ctx = context.Background()

var logger *zap.Logger

func main() {
	logger, _ = zap.NewDevelopment()
	log.SetFlags(log.LstdFlags | log.Lshortfile)

	host := os.Getenv("REDIS_HOST")
	port := os.Getenv("REDIS_PORT")
	listName := os.Getenv("REDIS_LIST")
	password := os.Getenv("REDIS_KEY")

	rdb := redis.NewClient(&redis.Options{
		Addr:     fmt.Sprintf("%s:%s", host, port),
		Password: password, // no password set
		DB:       0,        // use default DB
	})

	for {
		val3, err := rdb.LPop(ctx, listName).Result()
		if err == redis.Nil {
			logger.Sugar().Infof("%s list is empty, waiting 3 seconds...", listName)
			time.Sleep(3 * time.Second)
		} else if err != nil {
			logger.Sugar().Panic(err)
		} else {
			logger.Sugar().Infof("processing list: %s and item: %s", listName, val3)
			time.Sleep(3 * time.Second)
		}
	}
}
